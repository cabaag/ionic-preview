WebBrowserPreview = require './ionic-view'
url = require "url"

module.exports =

   activate: ->
      atom.commands.add 'atom-text-editor', 'ionic: preview', ->
         atom.workspace.open "ionic://localhost:8100", split: "right"

      atom.workspace.addOpener (uri) ->
         try
            {protocol, host, pathname} = url.parse(uri)
         catch
            return
         return unless protocol is "ionic:"

         uri = url.parse(uri)
         uri.protocol = "http:"
         preview = new WebBrowserPreview(url: uri.format())

         preview.openViewer()
         return preview

   destroy  : ->
      preview.destroy()
