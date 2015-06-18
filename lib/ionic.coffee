WebBrowserPreview = require './ionic-view'
{CompositeDisposable} = require 'atom'
url = require 'url'

module.exports =
  ionicPreviewView: null

  config:
    autoStartServe:
      title: 'Autostart Serve'
      description: 'Automatically start ionic serve'
      type: 'boolean'
      default: false

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'ionic:preview': =>@preview()

    @subscriptions.add atom.workspace.addOpener (uri)->
      try
        {protocol, host, pathname} = url.parse(uri)
      catch
        returns
      return unless protocol is "ionic:"

      uri = url.parse(uri)
      uri.protocol = "http:"
      preview = new WebBrowserPreview(url: uri.format())

      preview.openViewer()
      preview

  preview: ->
    atom.workspace.open "ionic://localhost:8100", split: "right"

  # destroy: ->
  #   console.log "Destroying"
  #   @subscriptions.dispose()
  #   preview.destroy()
