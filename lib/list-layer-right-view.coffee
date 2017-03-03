{SelectListView, $$,$} = require 'atom-space-pen-views'
{Emitter} = require 'event-kit'
$ = window.$ = window.jQuery = require 'jquery'

module.exports =

  ListLayerRightView: class ListLayerRightView extends SelectListView
    initialize: ->
     super
     @emitter = new Emitter
     @addClass('tab')
     @focusFilterEditor()
     @filterEditorView.addClass("sub-rightview-filter")
     @textEditor = @filterEditorView.getModel()
     @textEditor.placeholderText = " 🔍　Search layer name"
     @layerList = []
    #  @layerList = [{name: 'layer-search', depth: 0}, {name: 'layer-anima', depth: 1}, {name: 'layer-backgroud', depth: 2},
    #                {name: 'button-login', depth: 3}, {name: 'view-backgroud', depth: 4}, {name: 'tabel-coffee', depth: 3},
    #                {name: 'view-font', depth: 3}, {name: 'view-left', depth: 4}, {name: 'button-search', depth: 3},
    #                {name: 'button-filter', depth: 2}, {name: 'view-editor', depth: 1}, {name: 'button-cancel', depth: 0}]
     @notifyLayerListChanged();

    viewForItem: (item) ->
      $$ ->
        @li class: 'list-selectable-item-ext', =>
          # @span class: 'fa fa-picture-o'
          # button:@span class: 'fa fa-square-o'
          # image:@span class: 'fa fa-square-o'
          # table:@span class: 'fa fa-table'
          # label:@span class: 'fa fa-text-width'
          # view:@span class: 'fa fa-sticky-note-o'
          @div class: '', =>
            depth = if item.depth > 0 then item.depth else 0
            @span class: 'list-layer-line-leading-white layer-indent-guide', '  ' while depth--
            # Prefix icon
            if item.name?.indexOf('WXImage') > -1
              @span class: 'fa fa-picture-o layer-prefix-image-icon', =>
                image:@span class: 'fa'
            else if item.name?.indexOf('WXText') > -1
              @span class: 'fa fa-text-width layer-prefix-text-icon', =>
                label:@span class: 'fa'
            else
              @span class: 'fa fa-columns layer-prefix-container-icon', =>
                view:@span class: 'fa'
            @span class: 'sub-rightview-font', '\<'+item.name+' />'

      # "<li class='list-nested-item list-selectable-item'><div class='list-item'>#{item}</div></li>"

    # Get the property name to use when filtering items.
    getFilterKey: (item) ->
      return 'name'

    # Get the filter query to use when fuzzy filtering the visible elements.
    getFilterQuery: ->
      super
      # @filterEditorView.getText()

    #unfocus will be call it
    cancel: ->
      console.log("canceled")

    confirmed: (item) ->
      # console.log("#{item} was selected")
      data = {
        id : item.id,
        name : item.name
      }
      atom.commands.dispatch(atom.views.getView(atom.workspace), "layer:selected", data)
      atom.commands.dispatch(atom.views.getView(atom.workspace), "layer:hovering", data)

    deactivate: ->
      @remove()

    cancelled: ->
      console.log("This view was cancelled")

    notifyLayerListChanged: ->
      @setItems(@layerList, ['view-editor','button-cancel'])

    # @param {Array.<LayerNode>} layerList
    updateLayerList: (flatLayer) ->
      @layerList = flatLayer;
      @notifyLayerListChanged()
