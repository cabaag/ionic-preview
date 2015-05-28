{$, ScrollView, View} = require 'atom-space-pen-views'
{BufferedProcess} = require 'atom'
http = require "http"
url = require "url"

module.exports =
class WebBrowserPreview extends View
   @process: null

   @content: (params) ->
      @iframe id:"frame", class: "iphone", src: params.url, sandbox: "allow-same-origin allow-scripts"

   getTitle: ->
      "Ionic: Preview"

   initialize: (params) ->
      me = $(@)
      # frame = me.children("#frame")
      @url = params.url
      @.on 'load', ->
         $(window).on 'resize', ->
            height = me[0].parentNode?.scrollHeight
            if height < me.height()
               me.css("transform", "scale(" + ((height - 100) / me.height()) + ")")
            else
               me.css("transform", "none")

   openViewer: ->
      me = @
      http.get(@url, ->
         me.go()
         atom.workspace.activateNextPane()
      ).on('error', ->
         atom.workspace.destroyActivePaneItem()
         if not atom.config.get 'ionic-preview.auto_start_serve'
            alert "First start ionic serve"
         else
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
      # frame = me.children("#frame")
      height = me[0].parentNode?.scrollHeight
      if height? and height < me.height()
         me.css("transform", "scale(" + ((height - 50) / me.height()) + ")")
      else
         me.css("transform", "none")
      me.css("display", "block")

   destroy: ->
      if @process?
         @process.kill()
         @process = null
