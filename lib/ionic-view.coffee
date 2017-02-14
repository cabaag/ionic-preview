{ View, $, $$ } = require 'atom-space-pen-views'
{ BufferedProcess } = require 'atom'
http = require "http"
url = require "url"

FrameView = require './views/frame-view.coffee'
DropdownDevices = require './views/dropdown-devices.coffee'

module.exports =
class WebBrowserPreview extends View
  @content: (params) ->
    @div class: "ionic-preview", =>
      @div class: 'header', =>
        @button class: 'icon icon-device-mobile', click: "toggleDropdownDevices"
        @button class: 'fa rotate-device', click: "rotateDevice"
        @input
          class: 'native-key-bindings address-bar',
          type: 'text',
          keyup: 'keyUp',
          outlet: 'addressBar'
        @button class: 'icon icon-home', click: "goToDefault"
        @button class: 'fa shutdown', click: "clickShutdownButton"
      @div class: 'footer', outlet: 'footer'
      @subview 'dropdownDevices', new DropdownDevices()
      @subview 'frameView', new FrameView(params.url)

  serialize: ->

  # Initialize pane
  initialize: (params) ->
    @active = true
    @actualLocation = @url = params.url
    @address = atom.config.get('ionic-preview.customAddress')
    @port = atom.config.get('ionic-preview.customPort')

    @device = {id: 'iphone-5', name: 'iPhone 5', width: 320, height: 568}

    # Open browser if auto start serve but theres and external existing
    # process of ionic serve else open browser or destroy pane
    if atom.config.get 'ionic-preview.autoStartServe'
      http.get(@url).on 'error', (error)=>
        alert "Starting serve"
        @startServe()
    else
      http.get(@url).on 'error', (error)->
        alert("First start ionic serve")
        atom.workspace.destroyActivePaneItem()

    $(document).ready =>
      @footer.text(@device.name + " - " + @device.height + "x" + @device.width)
      @frameView.init()

  destroy: =>
    @frameView.destroy()
    @shutdownServe()
    @active = false
    return

  getTitle: ->
    "Ionic: Preview"

  # Go to default location
  goToDefault: ->
    @frameView.navigateTo("http://#{@address}:#{@port}")

  toggleDropdownDevices: ->
    @dropdownDevices.toggle()

  changeDeviceView: (device)->
    @device = device
    @footer.text(@device.name + " - " + @device.height + "x" + @device.width)
    @dropdownDevices.close()
    @frameView.changeDeviceView(device.id)

  rotateDevice: ->
    @footer.text(@device.name + " - " + @device.height + "x" + @device.width)
    @frameView.rotate()

  # if ENTER reload the frame with the address provided
  keyUp: (event)->
    if event.keyCode is 13
      @frameView.navigateTo(@addressBar.val())
      @addressBar.blur()
    return

  # Start serve with commands
  startServe: ->
    command = 'ionic'
    args = ['serve', '-b', '--address', @address, '-p', @port]
    path = atom.project.getPaths()[0]
    options = { cwd: path }
    startedServer = new RegExp("Running dev server")

    stdout = (output) =>
      if /error/ig.exec(output)
        alert output

      if startedServer.test(output)
        setTimeout =>
          @frameView.navigateTo("http://#{@address}:#{@port}")
        , 500

    exit = (code) =>
      alert "Your first directory must be an ionic app"
      @clickShutdownButton()

    @bufferedProcess = new BufferedProcess({command, args, options, stdout, exit})
    return

  clickShutdownButton: =>
    atom.workspace.destroyActivePaneItem()

  shutdownServe: =>
    @bufferedProcess.kill() if @bufferedProcess
    return
