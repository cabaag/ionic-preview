{$, View} = require 'atom-space-pen-views'
{BufferedProcess} = require 'atom'
http = require "http"
url = require "url"

module.exports =
class WebBrowserPreview extends View
  @content: (params) ->
    @div =>
      class: "ionic-preview"
      # @button "Shutdown",
      #   id: "shutdown-serve"
      #   click: "shutdownServe"
      @iframe
        id:"frame"
        class: "iphone"
        src: params.url
        sandbox: "allow-same-origin allow-scripts"

  getTitle: ->
    "Ionic: Preview"

  initialize: (params) ->
    me = $(@)
    @url = params.url
    @.on 'load', ->
      $(window).on 'resize', ->
        console.log "Resizing"
        height = me[0].parentNode?.scrollHeight
        if height < me.height()
          me.css("transform", "scale( #{(height - 100) / me.height()} )")
        else
          me.css("transform", "none")

  openViewer: ->
    me = @
    http.get @url, ->
      me.go()
      atom.workspace.activateNextPane()
    .on 'error', ->
      atom.workspace.destroyActivePaneItem()
      if not atom.config.get 'ionic-preview.autoStartServe'
        alert "First start ionic serve"
      else
        me.startServe()

  go: ->
    me = $(@)
    frame = $(me.find('#frame')[0])
    @.src = @url
    # console.log frame
    height = me[0].parentNode?.scrollHeight
    if height? and height < frame.height()
      frame.css("transform", "scale(" + ((height - 50) / frame.height()) + ")")
    else
      frame.css("transform", "none")
    frame.css("display", "block")

  startServe: ->
    me = @
    command = 'ionic'
    args = ['serve', '-b']
    path = atom.project.getPaths()[0]
    options = {cwd: path}
    startedServer = new RegExp("Running dev server")
    stdout = (output)->
      if /error/ig.exec(output)
        alert output
      if startedServer.test(output)
        setTimeout ->
          atom.workspace.open "ionic://localhost:8100", split: "right"
          me.openViewer()
        , 2000
    exit = (code)->
      console.log("ionic serve exited with #{code}")
    @bufferedProcess = new BufferedProcess({command, args, options, stdout, exit})

  # shutdownServe: ->
  #   console.log @bufferedProcess
  #   me = @
  #   console.log me
  #   if @bufferedProcess?
  #     console.log "Killing"
  #     @bufferedProcess.kill()
  #   atom.workspace.destroyActivePaneItem()
