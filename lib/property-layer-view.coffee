{TextEditorView,ScrollView} = require 'atom-space-pen-views'
{Jscolor} = require './jscolor.js'
$ = window.$ = window.jQuery = require 'jquery'
require './jquery-ui.js'

module.exports =
  class PropertyLayerView extends ScrollView
    @elementDiv = null
    @content: ->
      @div class:'property-layer-view', =>
        @div class:'div-for-left-view',=>
          @i class:'fa fa-magic icon-for-left-view-label'
          @label('Layout')

        @div class:'div-layout-base',=>
          @label class: 'layout-label', 'Frame'
          @label class: 'layout-label-title', 'X'
          @input class:'text-base native-key-bindings mod',type:'number',max:'5999', name: 'name', outlet: 'frameX'
          @label class: 'layout-label-title', 'Y'
          @input class:'text-base native-key-bindings mod',type:'number',max:'5999', name: 'name', outlet: 'frameY'

          @label class: 'layout-label', ''
          @label class: 'layout-label-title', 'W'
          @input class:'text-base native-key-bindings mod',type:'number',max:'5999', name: 'name',step:'1', outlet: 'frameW'
          @label class: 'layout-label-title', 'H'
          @input class:'text-base native-key-bindings mod',type:'number',max:'5999', name: 'name',step:'1', outlet: 'frameH'

          @div class:'span-split'

          @label class: 'layout-label', 'Bounds'
          @label class: 'layout-label-title', 'X'
          @input class:'text-base native-key-bindings mod',type:'number',max:'5999', name: 'name', outlet: 'boundsX'
          @label class: 'layout-label-title', 'Y'
          @input class:'text-base native-key-bindings mod',type:'number',max:'5999', name: 'name', outlet: 'boundsY'

          @label class: 'layout-label', ''
          @label class: 'layout-label-title', 'W'
          @input class:'text-base native-key-bindings mod',type:'number',max:'5999', name: 'name', outlet: 'boundsW'
          @label class: 'layout-label-title', 'H'
          @input class:'text-base native-key-bindings mod',type:'number',max:'5999', name: 'name', outlet: 'boundsH'

          @div class:'span-split'

          @label class: 'layout-label', 'Center'
          @label class: 'layout-label-title', 'X'
          @input class:'text-base native-key-bindings mod',type:'number',max:'5999', name: 'name', outlet: 'centerX'
          @label class: 'layout-label-title', 'Y'
          @input class:'text-base native-key-bindings mod',type:'number',max:'5999', name: 'name', outlet: 'centerY'

          @div class:'span-split'

          @label class: 'layout-label', 'Layout Margins'
          @label class: 'layout-label-title', 'T'
          @input class:'text-base native-key-bindings mod',type:'number',max:'5999', name: 'name', outlet: 'marginT'
          @label class: 'layout-label-title', 'B'
          @input class:'text-base native-key-bindings mod',type:'number',max:'5999', name: 'name', outlet: 'marginB'

          @label class: 'layout-label', ''
          @label class: 'layout-label-title', 'L'
          @input class:'text-base native-key-bindings mod',type:'number',max:'5999', name: 'name', outlet: 'marginL'
          @label class: 'layout-label-title', 'R'
          @input class:'text-base native-key-bindings mod',type:'number',max:'5999', name: 'name', outlet: 'marginR'

        @div class:'div-for-left-view',=>
          @i class:'fa fa-clone icon-for-left-view-label'
          @label('View')

        @div outlet: 'viewDiv',class:'div-layout-base',=>
          @label class: 'layout-label', 'Corner Radius'
          @input class:'text-base-long native-key-bindings mod',type:'number',max:'5999', name: 'name', outlet: 'cornerRadius'
          @div class:'span-split'
          @label class: 'layout-label', 'Border Color'
          @input class:'jscolor text-base-long',name: 'name', outlet: 'borderColor'
          @div class:'span-split'
          @label class: 'layout-label', 'Border Width'
          @input class:'text-base-long native-key-bindings mod',type:'number',max:'5999', name: 'haha2', outlet: 'borderWidth'
          @div class:'span-split'

          @label class: 'layout-label', 'Alpha'
          @div class: 'slider-div-wrapper', =>
            @label class: 'label-alpha', '0.0', outlet: 'alpha'
            @div class: 'slider-div', id:'slider'
            $ ->
              $('#slider').slider({
                min:0
                max:1
                step:0.1
                range: "min"
                })

          @div class:'span-split'
          @label class: 'layout-label', 'Background'
          @input class:'jscolor text-base-long',name: 'name', outlet: 'backgroundColor'
          # @div class:'span-split'
          # @label class: 'layout-label', 'Tint'
          # @input class:'jscolor text-base-long',name: 'name'

        @div class:'div-for-left-view', outlet: 'labelDiv', =>
          @i class:'fa fa-font icon-for-left-view-label'
          @label('Text & Label')

          @div outlet: 'viewDiv',class:'div-layout-base',=>
            @label class: 'layout-label', 'Text Content'
            @input class:'text-base-long native-key-bindings mod',type:'input', name: 'name', outlet: 'textContent'
            @div class:'span-split'
            @label class: 'layout-label', 'Font-Size'
            @input class:'text-base-long native-key-bindings mod',type:'number',max:'5999', name: 'name', outlet: 'fontSize'
            @div class:'span-split'
            @label class: 'layout-label', 'Color'
            @input class:'jscolor text-base-long',name: 'name', outlet: 'fontColor'
            @div class:'span-split'
            @label class: 'layout-label', 'Font-Weight'
            @select class: "layer-select-box", name: "selGetter",  outlet: 'fontWeight', =>
              @option value: "normal", selected: true, "normal"
              @option value: "bold" , "bold"
            @div class:'span-split'
            @label class: 'layout-label', 'Text-Align'
            @select class: "layer-select-box", name: "selGetter", outlet: 'textAlign', =>
              @option value: "left", selected: true, "left"
              @option value: "center" , "center"
              @option value: "right" , "right"
            @div class:'span-split'
            @label class: 'layout-label', 'Font-Family'
            @input class:'text-base-long native-key-bindings mod',type:'input', name: 'name', outlet: 'fontFamily'

        @div class:'div-for-left-view', outlet: 'imageDiv', =>
          @i class:'fa fa-file-image-o icon-for-left-view-label'
          @label('Image')

          @div outlet: 'viewDiv',class:'div-layout-base',=>
            @label class: 'layout-label', 'Mode'
            @select class: "layer-select-box", name: "selGetter", outlet: 'imageMode', =>
              @option value: "stretch", selected: true, "stretch"
              @option value: "cover" , "cover"
              @option value: "contain" , "contain"
            @div class:'span-split'
            @div class:'wrapper', =>
              @div class:'bounding-box', outlet: 'imageContent'

    chooseSelector: (selector, option) ->
      for item in selector.options
        item.selected = if item.value == option then true else false

    updateProperties: (props) ->
      # console.log(props)
      # Layout
      @frameX.attr('value', props.frameX)
      @frameY.attr('value', props.frameY)
      @frameW.attr('value', props.frameW)
      @frameH.attr('value', props.frameH)
      @boundsX.attr('value', props.boundsX)
      @boundsY.attr('value', props.boundsY)
      @boundsW.attr('value', props.boundsW)
      @boundsH.attr('value', props.boundsH)
      @centerX.attr('value', props.centerX)
      @centerY.attr('value', props.centerY)
      @marginL.attr('value', props.marginL)
      @marginT.attr('value', props.marginT)
      @marginR.attr('value', props.marginR)
      @marginB.attr('value', props.marginB)

      # View
      @cornerRadius.attr('value', props.cornerRadius)
      @borderColor[0].jscolor.fromString(props.borderColor.substr(2))
      @borderWidth.attr('value', props.borderWidth)
      @alpha.text(props.alpha)

      $('#slider').slider({'value': props.alpha})
      @backgroundColor[0].jscolor.fromString(props.backgroundColor.substr(2))

      # Text & Label
      if props.layerType == 'label'
        @labelDiv[0].style.display = 'block'
        @textContent.attr('value', props.textContent)
        @fontSize.attr('value', props.fontSize)
        @fontColor[0].jscolor.fromString(props.fontColor.substr(2))
        @chooseSelector(@fontWeight[0], props.fontWeight)
        @chooseSelector(@textAlign[0], props.textAlign)
        @fontFamily.attr('value', props.fontMamily)
      else
        @labelDiv[0].style.display = 'none'

      # Image
      if props.layerType == 'image'
        @imageDiv[0].style.display = 'block'
        @chooseSelector(@imageMode[0], props.imageMode)
        @imageContent[0].style.backgroundImage = "url('#{props.imageUrl}')"
      else
        @imageDiv[0].style.display = 'none'

      # props.imageUrl = if props.imageUrl then props.imageUrl else 'https://img.alicdn.com/tps/TB1PPUKNFXXXXa0XVXXXXXXXXXX-64-64.png'
      # @imageContent[0].style.backgroundSize = props.imageMode
      # defaultWidth = 331    # 默认宽 width: 331px;
      # defaultHeight = 176   # 默认高 height: 176px;
      # width = if props.frameW <= 0 || props.frameH <= 0 then defaultWidth else props.frameW
      # height = if props.frameW <= 0 || props.frameH <= 0 then defaultHeight else props.frameH
      # scale = if height / width < defaultHeight / defaultWidth then defaultWidth / width else defaultHeight / height
      # width = width * scale
      # height = height * scale
      # @imageContent[0].style.width = "#{width}px"
      # @imageContent[0].style.height = "#{height}px"
