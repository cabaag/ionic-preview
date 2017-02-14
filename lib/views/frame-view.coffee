{ View, $ } = require 'atom-space-pen-views'

module.exports =
class FrameView extends View
  @content: (url)->
    @div class: 'frame-wrapper', =>
      @iframe
        id: "frame",
        class: "iphone-5",
        src: url,
        sandbox: "allow-same-origin allow-scripts",
        outlet: "frame"

  initialize: ->
    @address = atom.config.get('ionic-preview.customAddress')
    @port = atom.config.get('ionic-preview.customPort')
    @watchLocation()
    $(window).resize =>
      @resizeFrame(@parentView)

  destroy: =>
    clearInterval(@locationWatcher)

  init: =>
    setTimeout => @resizeFrame()

  # Resize the iframe to match the container
  resizeFrame: =>
    maxHeight = @parentView.height() - 100
    if maxHeight? and maxHeight < @frame.height()
      @frame.css("transform", "scale(#{maxHeight / @frame.height()})")

  # Get location of iframe
  getLocation: =>
    (@frame[0].contentWindow || @frame[0].contentDocument)?.location.href

  # Iframe navigates to location
  navigateTo: (url)=>
    @frame.attr('src', url)
    return

  # Add watcher when location of frame changes
  watchLocation: ->
    @locationWatcher = setInterval =>
      location = @getLocation()
      if @actualLocation isnt location
        @actualLocation = location
        @parentView.addressBar.val(location)
    , 200
    return

  changeDeviceView: (id)=>
    @frame.removeClass()
    @frame.addClass(id)
    # @resizeFrame()

  rotate: ->
    @frame.toggleClass('landscape')
