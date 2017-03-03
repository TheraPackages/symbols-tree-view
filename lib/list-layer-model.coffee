{CompositeDisposable} = require 'atom'

module.exports =

  ListLayerModel: class ListLayerModel
    @_idToLayerNode = {}
    @treeLayer = null
    @flatLayer = null

    constructor: (layerMutateListener) ->
      @layerMutateListener = layerMutateListener

      @_disposable = new CompositeDisposable
      @_disposable.add atom.commands.add 'atom-workspace', {
        'layer:updated': (domTree) => @layerUpdated(domTree.detail),
        'layer:inserted': (domDiff) => @layerInserted(domDiff.detail),
        'layer:removed': (domDiff) => @layerRemoved(domDiff.detail)
      }
      @_disposable.add atom.commands.add 'atom-workspace', {
        'thera-preview:server': (message) => @handlePreviewServerMessage(message.detail)
      }

    dispose: ->
      @layerMutateListener = null
      @_disposable.dispose()

    _notifyListener: ->
      if @layerMutateListener
        @layerMutateListener(@treeLayer, @flatLayer)
      else
        console.log("layerMutateListener not exists.")

    handlePreviewServerMessage: (message) ->
      if message?.connection?.status == "closed"
        console.log message
        @layerUpdated()


    layerUpdated: (domTree) ->
      @treeLayer = @_convertToLayerTree(domTree)
      @flatLayer = @_flattenLayer(@treeLayer)
      @_idToLayerNode = @_buildLayerIndex(@treeLayer)
      @_notifyListener()

    layerInserted: (domDiff) ->
      layerDiff = @_convertToLayerTree(domDiff)
      parent = @_idToLayerNode[layerDiff.parent]
      if parent
        parent.children = parent.children || []
        if layerDiff.previousSibling < 0 || parent.children.length == 0
          parent.children.splice(0, 0, layerDiff)
        else
          pos = 0
          while pos < parent.children.length && layerDiff.previousSibling != parent.children[pos].id
            pos += 1
          if pos < parent.children.length
            parent.children.splice(pos+1, 0, layerDiff)

      @flatLayer = @_flattenLayer(@treeLayer)
      @_idToLayerNode = @_buildLayerIndex(@treeLayer)
      @_notifyListener()

    layerRemoved: (domDiff) ->
      children = domDiff.children
      domDiff.children = [] # for efficiency

      layerDiff = @_convertToLayerTree(domDiff)
      parent = @_idToLayerNode[layerDiff.parent]
      if parent
        pos = 0
        while pos < parent.children.length && parent.children[pos].id != layerDiff.id
          pos += 1
        if pos < parent.children.length
          parent.children.splice(pos, 1)

      @flatLayer = @_flattenLayer(@treeLayer)
      @_idToLayerNode = @_buildLayerIndex(@treeLayer)
      @_notifyListener()

    # @param ref WebInspector.DataConverter
    _convertToLayerTree: (domTree) ->
      if !domTree
        return null

      layer = new LayerNode
      layer.id = domTree.id || domTree.nodeId
      layer.name = domTree.nodeName # omit system package path
      # layer.name = domTree.localName
      layer.type = domTree.nodeType
      layer.parent = domTree.parent
      layer.previousSibling = domTree.previousSibling
      layer.nextSibling = domTree.nextSibling

      if domTree.children and domTree.children.length > 0
        layer.children = []
        for child in domTree.children
          layer.children.push @_convertToLayerTree(child)
      return layer

    _flattenLayer: (layerTree) ->
      flatLayer = []
      @__flattenLayerRecursively(flatLayer, layerTree, 0)
      return flatLayer

    # Pre-order traversals
    __flattenLayerRecursively: (container, layerTree, depth) ->
      if !layerTree
        return

      layerTree.depth = depth
      container.push layerTree
      if layerTree.children and layerTree.children.length > 0
        for child in layerTree.children
          @__flattenLayerRecursively(container, child, depth + 1)

    _buildLayerIndex: (layerTree) ->
      index = {}
      @__buildLayerIndexRecursively(index, layerTree)
      return index

    __buildLayerIndexRecursively: (container, layerTree) ->
      if !layerTree
        return
      container[layerTree.id] = layerTree
      if layerTree.children and layerTree.children.length > 0
        for child in layerTree.children
          @__buildLayerIndexRecursively(container, child)


  LayerNode: class LayerNode

    constructor: () ->
      @id = -1        # number
      @name = null    # string
      @type = -1      # number
      @depth = 0      # number

      @parent = -1            # number
      @previousSibling = -1   # number
      @nextSibling = -1       # number
      @children = []          # Array<LayerNode>
