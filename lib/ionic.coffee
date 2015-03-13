WebBrowserPreviewView = require './ionic-view'
url = require "url"
http = require("http")

module.exports =
   activate: ->
      atom.commands.add 'atom-text-editor', 'ionic: preview', ->
         atom.workspace.open "ionic://localhost:8100", split: "right"

      atom.workspace.registerOpener (uri) ->
         try
            {protocol, host, pathname} = url.parse(uri)
         catch
            return
         return unless protocol is "ionic:"

         uri = url.parse(uri)
         uri.protocol = "http:"

         preview = new WebBrowserPreviewView(url: uri.format())

         http.get(uri.format(), ->
            preview.go()
            atom.workspace.activateNextPane()
         ).on('error', ->
            atom.workspace.destroyActivePaneItem()
            alert("You have to start the ionic server first!")
         )

         return preview
