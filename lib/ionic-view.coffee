{$, ScrollView, View, BufferedProcess} = require 'atom'
http = require "http"
url = require "url"

module.exports =
class WebBrowserPreview extends View
   @process: null

   @content: (params) ->
      @div =>
         @h1 'Hola'
         @iframe id:"frame", class: "iphone", src: params.url, sandbox: "allow-same-origin allow-scripts"

   getTitle: ->
      "Ionic: Preview"

   initialize: (params) ->
      me = $(@)
      frame = me.children("#frame")
      @url = params.url
      me.load ->
         $(window).resize ->
            height = frame.parentNode?.scrollHeight
            if height < frame.height()
               frame.css("transform", "scale(" + ((height - 50) / frame.height()) + ")")
            else
               frame.css("transform", "none")

   openViewer: ->
      me = @
      http.get(@url, ->
         console.log("Preview")
         me.go()
         atom.workspace.activateNextPane()
      ).on('error', ->
         atom.workspace.destroyActivePaneItem()
         me.startServe()
         setTimeout( ->
            atom.workspace.open "ionic://localhost:8100", split: "right"
            me.openViewer()
         , 2000)
      )

   startServe :->
      command = 'ionic'
      args = ['serve', '-b']
      options = {
         cwd : atom.project.getPath()
      }
      stdout = (output) -> console.log(output)
      exit = (code) ->
         console.log("ionic serve exited with #{code}")
         @bufferedProcess = null

      @process = new BufferedProcess({command, args, options, stdout, exit})

   go: ->
      me = $(@)
      @.src = @url
      frame = me.children("#frame")
      height = frame[0].parentNode?.scrollHeight
      if height? and height < me.height()
         frame.css("transform", "scale(" + ((height - 50) / frame.height()) + ")")
      else
         frame.css("transform", "none")
      frame.css("display", "block")

   destroy: ->
      if @process?
         @process.kill()
         @process = null
