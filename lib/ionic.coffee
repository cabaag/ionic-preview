{ CompositeDisposable } = require 'atom'
url = require 'url'
WebBrowserPreview = require './ionic-view'

module.exports =
  ionicPreviewView: null
  config:
    autoStartServe:
      title: 'Autostart Serve'
      description: 'Automatically start ionic serve'
      type: 'boolean'
      default: false
    customAddress:
      title: 'Address'
      description: 'Changes address for ionic-view'
      type: 'string'
      default: 'localhost'
    customPort:
      title: 'Port'
      description: 'Changes port for ionic-view'
      type: 'integer'
      default: 8100

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'ionic:preview': => @preview()

    @subscriptions.add atom.workspace.addOpener (uri)=>
      try
        { protocol, host, pathname } = url.parse(uri)
      catch
        return
      return unless protocol is "ionic:"

      uri = url.parse(uri)
      uri.protocol = "http:"
      preview = new WebBrowserPreview(url: uri.format())
      if not atom.config.get 'ionic-preview.autoStartServe'
        preview.openViewer()
      else
        preview.init()
      preview

  preview: ->
    address =  atom.config.get('ionic-preview.customAddress')
    port = atom.config.get('ionic-preview.customPort')
    atom.workspace.open "ionic://#{address}:#{port}", split: "right"

  destroy: ->
    @subscriptions.dispose()
