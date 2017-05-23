SymbolsTreeView = require './symbols-tree-view'
PropertyLayerViewView = require './property-layer-view'
{PropertyLayerModel, LayerProperty} = require './property-layer-model'

module.exports =
  config:
    autoToggle:
      type: 'boolean'
      default: true
      description: 'If this option is enabled then symbols-tree-view will auto open when you open files.'
    scrollAnimation:
      type: 'boolean'
      default: true
      description: 'If this option is enabled then when you click the item in symbols-tree it will scroll to the destination gradually.'
    autoHide:
      type: 'boolean'
      default: false
      description: 'If this option is enabled then symbols-tree-view is always hidden unless mouse hover over it.'
    zAutoHideTypes:
      title: 'AutoHideTypes'
      type: 'string'
      description: 'Here you can specify a list of types that will be hidden by default (ex: "variable class")'
      default: ''
    sortByNameScopes:
      type: 'string'
      description: 'Here you can specify a list of scopes that will be sorted by name (ex: "text.html.php")'
      default: ''


  symbolsTreeView: null
  propertyLayerViewView: null
  modalPanel: null
  propertyLayerModel: null

  activate: (state) ->
    @symbolsTreeView = new SymbolsTreeView(state.symbolsTreeViewState)
    @propertyLayerViewView = new PropertyLayerViewView(state.symbolsTreeViewState)
    @modalPanel = atom.workspace.addRightPanel(item: @propertyLayerViewView, visible: false)
    @propertyLayerModel = new PropertyLayerModel (props) =>
      @propertyLayerViewView.updateProperties(props)

    atom.commands.add 'atom-workspace', 'symbols-tree-view:toggle': (activateIndex) =>
      @symbolsTreeView.toggle(activateIndex.detail)
      #if @modalPanel.isVisible()
      # @modalPanel.hide()
      #else
        #@modalPanel.show()

    atom.commands.add 'atom-workspace', 'modalPanel:show': =>
      @modalPanel.show()
    atom.commands.add 'atom-workspace', 'modalPanel:hide': =>
      @modalPanel.hide()



    atom.config.observe 'tree-view.showOnRightSide', (value) =>
      if @symbolsTreeView.hasParent()
        @symbolsTreeView.remove()
        @symbolsTreeView.populate()
        @symbolsTreeView.attach()

    # atom.config.observe "symbols-tree-view.autoToggle", (enabled) =>
    #   if enabled
    #     @symbolsTreeView.toggle() unless @symbolsTreeView.hasParent()
    #     #@modalPanel.show()
    #   else
    #     @symbolsTreeView.toggle() if @symbolsTreeView.hasParent()
    #     #@modulePanel.hide() if @modulePanel


  deactivate: ->
    # atom.config.set('symbols-tree-view.autoToggle',true)
    @symbolsTreeView.destroy()
    @modalPanel.destroy()
    # @propertyLayerViewView.destroy()

  serialize: ->
    symbolsTreeViewState: @symbolsTreeView.serialize()
    propertyLayerViewViewState: @propertyLayerViewView.serialize()

  getProvider: ->
    view = @symbolsTreeView

    providerName: 'symbols-tree-view'
    getSuggestionForWord: (textEditor, text, range) =>

      range: range
      callback: ()=>
        view.focusClickedTag.bind(view)(textEditor, text)
