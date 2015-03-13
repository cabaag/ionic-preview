IonicPreviewView = require './ionic-preview-view'
{CompositeDisposable} = require 'atom'

module.exports = IonicPreview =
  ionicPreviewView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @ionicPreviewView = new IonicPreviewView(state.ionicPreviewViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @ionicPreviewView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'ionic-preview:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @ionicPreviewView.destroy()

  serialize: ->
    ionicPreviewViewState: @ionicPreviewView.serialize()

  toggle: ->
    console.log 'IonicPreview was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
