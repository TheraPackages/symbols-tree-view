{Point, Range} = require 'atom'
{$, jQuery,TextEditorView, View} = require 'atom-space-pen-views'
{TreeView} = require './tree-view'

TagGenerator = require './tag-generator'
TagParser = require './tag-parser'
SymbolsContextMenu = require './symbols-context-menu'
{ListLayerRightView} = require './list-layer-right-view'
{ListLayerModel} = require './list-layer-model'

$ = window.$ = window.jQuery = require 'jquery'
require './jquery-ui.js'

INDEX_OF_LAYERS_TAB = 1
INDEX_OF_DEBUG_TAB = 2

module.exports =
  class SymbolsTreeView extends View
    @content: ->
      @div id:'symbols-tabs',style:"border-width:0;background:transparent;display:flex; flex-direction:column;",class:"symbols-tabs", =>
        @ul outlet: 'selectTabUl',=>
            @li class:'button hvr-hang' ,=>
              @a class:'symbols-tab-li', href:'#symbols-tabs-1',' func&val', =>
                @span class:'fa fa-code'
            @li class:'button hvr-hang  symbols-tab-li' ,=>
              @a class:'symbols-tab-li', href:'#symbols-tabs-2',' Layers', =>
                @span class:'fa fa-puzzle-piece'
            @li class:'button hvr-hang  symbols-tab-li' ,=>
              @a class:'symbols-tab-li', href:'#symbols-tabs-3',' Debug', =>
                @span class:'fa fa-bug'


        @div id:'symbols-tabs-1', class: 'div-for-symbol-tab', =>
          @div class:'div-for-left-view',=>
            @i class:'fa fa-puzzle-piece icon-for-left-view-label'
            @label('All Functions And Values')
          @div class:'symbols-tree-view', outlet: 'funcDiv'

        @div id:'symbols-tabs-2', class: 'div-for-symbol-tab', =>
          @div class:'div-for-left-view',=>
            @i class:'fa fa-code icon-for-left-view-label'
            @label('All Of Layers')
          @div class:'div-for-symbol-tree', outlet: 'layerDiv'

        @div id:'symbols-tabs-debug', class: 'thera-debug-tab', style: 'display:none;'

        # @div id:'symbols-tabs-3', class: 'div-for-symbol-tab'
        #@div class: 'symbols-tree-view-top tool-panel focusable-panel',outlet:'topDiv'
        #@div class:'div-for-left-view',=>
          #@i class:'fa fa-code icon-for-left-view-label'
          #@label('All Functions And Values')
        #@div class: 'symbols-tree-view tool-panel focusable-panel',outlet:'bottomDiv'
    # $ ->
    #   $('#symbols-tabs').tabs activate: (event, ui) ->
    #     #if 0 modalPanel close if 1 modalPanel view
    #     index4select = $("#symbols-tabs").tabs('option', 'active')
    #     if index4select != INDEX_OF_LAYERS_TAB
    #       atom.commands.dispatch(atom.views.getView(atom.workspace), "modalPanel:hide")
    #
    #     else
    #       atom.commands.dispatch(atom.views.getView(atom.workspace), "modalPanel:show")
    #
    #     if index4select == INDEX_OF_DEBUG_TAB
    #       atom.commands.dispatch(atom.views.getView(atom.workspace), "modalPanel:show-debug-panel")
    #     else
    #       atom.commands.dispatch(atom.views.getView(atom.workspace), "modalPanel:hide-debug-panel")
    #
    #     return

    registerListener: ->
      $('#symbols-tabs').tabs activate: (event, ui) ->
        #if 0 modalPanel close if 1 modalPanel view
        index4select = $("#symbols-tabs").tabs('option', 'active')
        if index4select != INDEX_OF_LAYERS_TAB
          atom.commands.dispatch(atom.views.getView(atom.workspace), "modalPanel:hide")

        else
          atom.commands.dispatch(atom.views.getView(atom.workspace), "modalPanel:show")

        if index4select == INDEX_OF_DEBUG_TAB
          atom.commands.dispatch(atom.views.getView(atom.workspace), "modalPanel:show-debug-panel")
        else
          atom.commands.dispatch(atom.views.getView(atom.workspace), "modalPanel:hide-debug-panel")

        return

    initialize: ->
      @treeView = new TreeView
      @funcDiv.append(@treeView)

      @listLayersView = new ListLayerRightView
      @listLayersView.addClass('list-layers-view')
      @layerDiv.append(@listLayersView)
      #@append(@treeView)
      @listLayerModel = new ListLayerModel (treeLayer, flatLayer) =>
        @listLayersView.updateLayerList(flatLayer)

      @cachedStatus = {}
      @contextMenu = new SymbolsContextMenu
      @autoHideTypes = atom.config.get('symbols-tree-view.zAutoHideTypes')

      @treeView.onSelect ({node, item}) =>
        if item.position.row >= 0 and editor = atom.workspace.getActiveTextEditor()
          screenPosition = editor.screenPositionForBufferPosition(item.position)
          screenRange = new Range(screenPosition, screenPosition)
          {top, left, height, width} = editor.pixelRectForScreenRange(screenRange)
          bottom = top + height
          desiredScrollCenter = top + height / 2
          unless editor.getScrollTop() < desiredScrollCenter < editor.getScrollBottom()
            desiredScrollTop =  desiredScrollCenter - editor.getHeight() / 2

          from = {top: editor.getScrollTop()}
          to = {top: desiredScrollTop}

          step = (now) ->
            editor.setScrollTop(now)

          done = ->
            editor.scrollToBufferPosition(item.position, center: true)
            editor.setCursorBufferPosition(item.position)
            editor.moveToFirstCharacterOfLine()

          jQuery(from).animate(to, duration: @animationDuration, step: step, done: done)

      atom.config.observe 'symbols-tree-view.scrollAnimation', (enabled) =>
        @animationDuration = if enabled then 300 else 0

      @minimalWidth = 5
      @originalWidth = atom.config.get('symbols-tree-view.defaultWidth')
      atom.config.observe 'symbols-tree-view.autoHide', (autoHide) =>
        unless autoHide
          @width(@originalWidth)
        else
          @width(@minimalWidth)

    # getEditor: -> atom.workspace.getCenter().getActivePaneItem() #atom.workspace.getActiveTextEditor()
    getEditor: -> atom.workspace.getCenter().getActiveTextEditor()
    getScopeName: (item)-> item?.getGrammar()?.scopeName

    populate: (editor) ->
      unless editor
        editor = @getEditor()

      unless editor
        @hide()
        return

      @generateTags(editor.getPath(), (@getScopeName editor))
      @show()

      @onEditorSave = editor.onDidSave (state) =>
        filePath = editor.getPath()
        @generateTags(filePath, (@getScopeName editor))

      @onChangeRow = editor.onDidChangeCursorPosition ({oldBufferPosition, newBufferPosition}) =>
        if oldBufferPosition.row != newBufferPosition.row
          @focusCurrentCursorTag()

    focusCurrentCursorTag: ->
      if editor = @getEditor()
        row = editor.getCursorBufferPosition().row
        return unless @parser
        return unless @parser.getNearestTag
        tag = @parser.getNearestTag(row)
        return unless tag

        item = @treeView.getSelectedItem()
        unless item
          @treeView.select(tag)
        else
          @treeView.select(tag) unless item.position?.row == tag.position?.row

    focusClickedTag: (editor, text) ->
      if editor = @getEditor()
        if @parser
          tag =  (t for t in @parser.tags when t.name is text)[0]
          @treeView.select(tag)
          # imho, its a bad idea =(
          jQuery('.list-item.list-selectable-item.selected').click()

    generateTags: (filePath, scope) ->
      new TagGenerator(filePath, scope).generate().done (tags) =>
        @parser = new TagParser(tags, scope)
        {root, types} = @parser.parse()
        @treeView.setRoot(root)
        # @updateContextMenu(types)
        @focusCurrentCursorTag()

        if (@autoHideTypes)
          for type in types
            if(@autoHideTypes.indexOf(type) != -1)
              @treeView.toggleTypeVisible(type)
              @contextMenu.toggle(type)

    # Returns an object that can be retrieved when package is activated
    serialize: ->

    # Tear down any state and detach
    destroy: ->
      @element.remove()
      @listLayerModel.dispose();

    attach: ->
      if atom.config.get('tree-view.showOnRightSide')
        @panel = atom.workspace.addLeftPanel(item: this)
      else
        @panel = atom.workspace.addRightPanel(item: this)

    attached: ->
      @registerListener()
      @onChangeEditor = atom.workspace.getCenter().onDidChangeActivePaneItem (item) =>
        return unless item
        return unless item.__proto__.constructor.name is "TextEditor"
        @removeEventForEditor()
        @populate(item)

      @onChangeAutoHide = atom.config.observe 'symbols-tree-view.autoHide', (autoHide) =>
        unless autoHide
          @off('mouseenter mouseleave')
        else
          @mouseenter (event) =>
            @stop()
            @animate({width: @originalWidth}, duration: @animationDuration)

          @mouseleave (event) =>
            @stop()
            if atom.config.get('tree-view.showOnRightSide')
              @animate({width: @minimalWidth}, duration: @animationDuration) if event.offsetX > 0
            else
              @animate({width: @minimalWidth}, duration: @animationDuration) if event.offsetX <= 0

      # @on "contextmenu", (event) =>
      #   left = event.pageX
      #   if left + @contextMenu.width() > atom.getSize().width
      #     left = left - @contextMenu.width()
      #   @contextMenu.css({left: left, top: event.pageY})
      #   @contextMenu.show()
      #   return false #disable original atom context menu

    removeEventForEditor: ->
      @onEditorSave?.dispose()
      @onChangeRow?.dispose()

    detached: ->
      @onChangeEditor?.dispose()
      @onChangeAutoHide?.dispose()
      @removeEventForEditor()
      @off "contextmenu"

    remove: ->
      super
      @panel.destroy()

    # Toggle the visibility of this view
    toggle: (option) ->
      {activateIndex, show} = option if option
      if @hasParent()
        if @panel.isVisible() and not show
          #需要断掉VIEW的链接
          @panel.hide()
        else
          @panel.show()
      else
        @populate()
        @attach()

      index = activateIndex ? activateIndex : 0
      $("#symbols-tabs").tabs({ active: index })

    # Show view if hidden
    showView: ->
      if not @hasParent()
        @populate()
        @attach()


    # Hide view if visisble
    hideView: ->
      if @hasParent()
        @remove()
