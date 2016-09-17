{ $, View } = require 'atom-space-pen-views'
{ BufferedProcess } = require 'atom'
http = require "http"
url = require "url"

module.exports =
class WebBrowserPreview extends View
  @content: (params) ->
    @div
      id: "ionic-preview"
      =>
        @div
          id: 'header'
          =>
            @div 'localhost:8100',
              id: 'address'
            @button "Shutdown",
              id: "shutdown-serve"
              click: "shutdownServe"
        @iframe
          id: "frame"
          class: "iphone"
          src: params.url
          sandbox: "allow-same-origin allow-scripts"

  getTitle: ->
    "Ionic: Preview"

  initialize: (params) ->
    @url = params.url
    @address = atom.config.get('ionic-preview.addressCustom')
    @port = atom.config.get('ionic-preview.portCustom')
    if atom.config.get 'ionic-preview.autoStartServe'
      alert "Starting ionic serve"
      @startServe()
    # Resize the viewer
    # $(window).resize ->
    #   console.log "resize"
    #   height = me[0].parentNode?.scrollHeight
    #   console.log height
    #   console.log me.height()
    #   if height < me.height()
    #     me.css("transform", "scale( #{(height - 100) / me.height()} )")
    #   else
    #     me.css("transform", "none")

  detached: ->
    @shutdownServe()

  openViewer: ->
    # Open viewer on right if cant auto start serve if its configurated
    console.log @url
    http.get @url, =>
      @init()
    .on 'error', (error)->
      atom.workspace.destroyActivePaneItem()
      if not atom.config.get 'ionic-preview.autoStartServe'
        alert "First start ionic serve"


  init: ->
    frame = $(@find('#frame')[0])
    if @checkFrameAddress()
      # Resize the iframe to match the container
      height = @[0].parentNode?.scrollHeight
      if height? and height < frame.height()
        frame.css("transform", "scale(" + ((height - 50) / frame.height()) + ")")
      else
        frame.css("transform", "none")
      frame.css("display", "block")

      # Changes the address of ionic serve
      $(document).ready =>
        $('#header #address').text("#{@address}:#{@port}")
    else
      alert 'Address or port doesnt match with the settings'
      atom.workspace.destroyActivePaneItem()
    return

  checkFrameAddress: ->
    # Check if address and port of the ionic-view
    # are the same of the ionic serve
    frame = $(@).find('#frame')[0]
    addressTmp = frame.src.replace(/http:\/\//, '').replace(/:.*\//, '')
    portTmp = frame.src.replace(/http.*:/, '').replace(/:.*\//, '').replace(/\//, '')
    portTmp = parseInt(portTmp)
    return @address is addressTmp and @port is portTmp

  startServe: ->
    command = 'ionic'
    args = ['serve', '-b', '--address', @address, '-p', @port]
    path = atom.project.getPaths()[0]
    options = {cwd: path}
    startedServer = new RegExp("Running dev server")
    frame = $(@).find('#frame')[0]

    stdout = (output)=>
      if /error/ig.exec(output)
        alert output
      if startedServer.test(output)
        setTimeout ->
          frame.contentWindow.location.reload(true)
        , 1000
    exit = (code)->
      alert code
      console.error("ionic serve exited with #{code}")

    @bufferedProcess = new BufferedProcess({command, args, options, stdout, exit})
    return

  shutdownServe: =>
    if @bufferedProcess?
      console.log "Killing"
      @bufferedProcess.kill()
    atom.workspace.destroyActivePaneItem()
