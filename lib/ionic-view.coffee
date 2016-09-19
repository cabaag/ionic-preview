{ View, $, $$ } = require 'atom-space-pen-views'
{ BufferedProcess } = require 'atom'
http = require "http"
url = require "url"

FrameView = require './views/frame-view.coffee'

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
        @button class: 'icon icon-home', click: "goToDefault"
        @button "Shutdown",
          id: "shutdown-serve"
          click: "clickShutdownButton"
      @subview 'frameView', new FrameView(params.url)

  serialize: ->

  # Initialize pane
  initialize: (params) ->
    @active = true
    @actualLocation = @url = params.url
    @address = atom.config.get('ionic-preview.customAddress')
    @port = atom.config.get('ionic-preview.customPort')

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
