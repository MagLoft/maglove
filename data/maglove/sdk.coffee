$ ->
  class MagLoveSdk
  
    constructor: (config={})->
      @config = config
      @$hoverElement = null
      @initUIHandlers()
  
    initUIHandlers: ->
      $("._typeloft_widget").hover (e)=>
        @$hoverElement.removeClass("__active_widget") if @$hoverElement
        @$hoverElement = $(e.currentTarget)
        @$hoverElement.addClass("__active_widget")
        e.preventDefault()
        e.stopPropagation()
        false
    
      $("._typeloft_widget").click ->
        console.log "click widget"
      

  sdk = new MagLoveSdk()
