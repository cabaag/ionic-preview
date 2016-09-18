{ View, $, $$ } = require 'atom-space-pen-views'
{ BufferedProcess } = require 'atom'
http = require "http"
url = require "url"

module.exports =
class WebBrowserPreview extends View
  @content: (params) ->
    @div class: "ionic-preview", =>
      @div class: 'header', =>
        @input
          class: 'native-key-bindings address-bar',
          type: 'text',
          keyup: 'keyUp',
          outlet: 'addressBar'
        @button "Shutdown",
          id: "shutdown-serve"
          click: "shutdownServe"
      @iframe
        outlet: 'frame',
        id: "frame",
        class: "iphone",
        src: params.url,
        sandbox: "allow-same-origin allow-scripts"
        onerror: 'error'

  getTitle: ->
    "Ionic: Preview"

  # Initialize pane
  initialize: (params) ->
    @url = params.url
    @address = atom.config.get('ionic-preview.customAddress')
    @port = atom.config.get('ionic-preview.customPort')
    if atom.config.get 'ionic-preview.autoStartServe'
      # Open browser if auto start serve but theres and external existing
      # process of ionic serve
      http.get @url, =>
        @openViewer()
      .on 'error', (error)=>
        alert "Starting serve"
        @startServe()
    @checkIfLocationHasChanged()
    @location = @url


  detached: =>
    clearInterval(@locationWatcher)
    @shutdownServe()

  # Check if url is avaliable and initialize elements, if not destroy pane and
  # throw alert
  openViewer: ->
    http.get @url, =>
      @init()
    .on 'error', (error)->
      atom.workspace.destroyActivePaneItem()
      if not atom.config.get 'ionic-preview.autoStartServe'
        alert "First start ionic serve"

  # Initialize frame
  init: ->
    # frame = $(@find('#frame')[0])
    if @checkFrameAddress()
      # Resize the iframe to match the container
      height = @[0].parentNode?.scrollHeight
      if height? and height < @frame.height()
        @frame.css("transform", "scale(" + ((height - 50) / @frame.height()) + ")")
      else
        @frame.css("transform", "none")
      @frame.css("display", "block")

      # Changes the address of ionic serve
      $(document).ready =>
        me = @
        widthInput = @addressBar.width()
        me.addressBar.val("http://#{@address}:#{@port}")
    else
      alert 'Address or port doesnt match with the settings'
      atom.workspace.destroyActivePaneItem()
    return

  checkFrameAddress: ->
    # Check if address and port of the ionic-view are the same of the ionic serve
    address = @frame.attr('src')
    # Extract address
    addressTmp = address.replace(/http:\/\//, '').replace(/:.*/, '')
    # Extract port
    portTmp = parseInt address.replace(/http.*:/, '').replace(/:.*\//, '')
    @address is addressTmp and @port is portTmp

  # if ENTER reload the frame with the address provided
  keyUp: (event)->
    if event.keyCode is 13
      @frame.attr('src', @addressBar.val())
      @addressBar.blur()
    return

  checkIfLocationHasChanged: ->
    @locationWatcher = setInterval =>
      location = (@frame[0].contentWindow || @frame[0].contentDocument).location.href
      if @location isnt location
        @location = location
        @addressBar.val(location)
    , 500
    return

  startServe: ->
    command = 'ionic'
    args = ['serve', '-b', '--address', @address, '-p', @port]
    path = atom.project.getPaths()[0]
    options = {cwd: path}
    startedServer = new RegExp("Running dev server")

    stdout = (output)=>
      if /error/ig.exec(output)
        alert output
      if startedServer.test(output)
        setTimeout =>
          @frame.attr('src', "http://#{@address}:#{@port}")
        , 2000
    exit = (code)=>
      alert "Your first directory must be an ionic app"
      console.error("ionic serve exited with #{code}")
      @shutdownServe()

    @bufferedProcess = new BufferedProcess({command, args, options, stdout, exit})
    return

  shutdownServe: =>
    if @bufferedProcess?
      @bufferedProcess.kill()
    atom.workspace.destroyActivePaneItem()
    return
