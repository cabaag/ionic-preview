{ CompositeDisposable } = require 'atom'
url = require 'url'
WebBrowserPreview = require './ionic-view'

CMD_TOOGLE = "ionic:preview"

view = undefined
pane = undefined
item = undefined

module.exports = IonicPreview =

  activate: (state)->
    console.log state
    atom.commands.add 'atom-workspace', CMD_TOOGLE, => @toggleView()
    return

  deactivate: ->
    return

  toggleView: ->
    unless view and view.active
      address =  atom.config.get('ionic-preview.customAddress')
      port = atom.config.get('ionic-preview.customPort')
      uri = "http://#{address}:#{port}"

      view = new WebBrowserPreview(url: uri)

      atom.workspace.getActivePane().splitRight()
      pane = atom.workspace.getActivePane()
      item = pane.addItem(view, 0)

      pane.activateItem(item)
    else
      pane.destroyItem(item)
    return

  serialize: ->

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
