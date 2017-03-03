{CompositeDisposable} = require 'atom'

module.exports =

  PropertyLayerModel: class PropertyLayerModel

    constructor: (propertyUpdateListener) ->
      @propertyUpdateListener = propertyUpdateListener

      @subscriptions = new CompositeDisposable
      @subscriptions.add atom.commands.add 'atom-workspace', {
        'layer:property': (styles) => @computedStyleForNode(styles.detail)
      }
      @subscriptions.add atom.commands.add 'atom-workspace', {
        'thera-preview:server': (message) => @handlePreviewServerMessage(message.detail)
      }

    dispose: ->
      @subscriptions.dispose()

    handlePreviewServerMessage: (message) ->
      if message?.connection?.status == "closed"
        console.log message
        @computedStyleForNode({})

    getStyle: (styles, attr, def) ->
      return if styles and styles[attr] then styles[attr] else def

    getColor: (styles, attr, def) ->
      value = if styles and styles[attr] then styles[attr] else ''
      return @formatColor(value)

    formatColor: (color) -> # Format color to 8Byte length
      color = color + ''
      color = if !color || color == '0' then '00000000' else color
      color = if color.length < 6 then new Array(6-color.length+1).join('0')+color else color
      color = if color.length == 6 then 'ff' + color else color
      color = if color.length < 8 then new Array(8-color.length+1).join('0')+color else color
      return color

    computedStyleForNode: (styles) ->
      console.log(styles)
      props = new LayerProperty
      props.frameX = @getStyle(styles, 'left', 0)
      props.frameY = @getStyle(styles, 'top', 0)
      props.frameW = @getStyle(styles, 'width', 0)
      props.frameH = @getStyle(styles, 'height', 0)

      props.boundsX = @getStyle(styles, 'x', 0)
      props.boundsY = @getStyle(styles, 'y', 0)
      props.boundsW = @getStyle(styles, 'width', 0)
      props.boundsH = @getStyle(styles, 'height', 0)

      props.centerX = @getStyle(styles, 'pivot-x', 0)
      props.centerY = @getStyle(styles, 'pivot-y', 0)

      props.marginL = @getStyle(styles, 'margin-left', 0)
      props.marginT = @getStyle(styles, 'margin-top', 0)
      props.marginR = @getStyle(styles, 'margin-right', 0)
      props.marginB = @getStyle(styles, 'margin-bottom', 0)

      props.cornerRadius = @getStyle(styles, 'corner-radius', 0)
      props.borderColor = @getColor(styles, 'border-color', '')
      props.borderWidth = @getStyle(styles, 'border-width', 0)
      props.alpha = @getStyle(styles, 'alpha', 1.0)
      props.backgroundColor = @getColor(styles, 'background-color', '')

      props.textContent = @getStyle(styles, 'text-content', '')
      props.fontSize = @getStyle(styles, 'font-size', '')
      props.fontColor = @getColor(styles, 'font-color', '')
      props.fontWeight = @getStyle(styles, 'font-weight', '')
      props.textAlign = @getStyle(styles, 'text-align', '')
      props.fontMamily = @getStyle(styles, 'font-family', '')
      if styles.hasOwnProperty('text-content') or styles.hasOwnProperty('font-size') or styles.hasOwnProperty('font-color') or styles.hasOwnProperty('font-weight') or styles.hasOwnProperty('text-align') or styles.hasOwnProperty('font-family')
        props.layerType = 'label'

      props.imageUrl = @getStyle(styles, 'image-url', '')
      props.imageMode = @getStyle(styles, 'image-mode', '')
      if styles.hasOwnProperty('image-url') or styles.hasOwnProperty('image-mode')
        props.layerType = 'image'

      if @propertyUpdateListener
        @propertyUpdateListener(props)


  LayerProperty: class LayerProperty
    constructor: () ->
      # Layout
      @frameX = 0
      @frameY = 0
      @frameW = 0
      @frameH = 0
      @boundsX = 0
      @boundsY = 0
      @boundsW = 0
      @boundsH = 0
      @centerX = 0
      @centerY = 0
      @marginL = 0
      @marginT = 0
      @marginR = 0
      @marginB = 0
      # View
      @cornerRadius = 0.0
      @borderColor = ""
      @borderWidth = 0.0
      @alpha = 1.0
      @backgroundColor = ""
      # Text & Label
      @textContent = ""
      @fontSize = 0.0
      @fontColor = ""
      @fontWeight = "normal"
      @textAlign = "left"
      @fontMamily = ""
      # Image
      @imageUrl = ""
      @imageMode = ""
      # LayerType
      @layerType = ""
