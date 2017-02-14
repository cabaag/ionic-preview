{ View, $ } = require 'atom-space-pen-views'
# WebBrowserPreview = require '../ionic-view'

devices = [
  {id: 'iphone-5', name: 'iPhone 5', width: 320, height: 568}
  {id: 'iphone-6', name: 'iPhone 6', width: 375, height: 667}
  {id: 'iphone-6-plus', name: 'iPhone 6 Plus', width: 414, height: 763},
  # {id: 'nexus-5x', name: 'Nexus 5X', width: 412, height: 732},
  {id: 'nexus-6p', name: 'Nexus 6P', width: 412, height: 732},
  {id: 'samsung-galaxy-s6', name: 'Samsung Galxy S6', width: 360, height: 640},
  {id: 'ipad', name: 'iPad', width: 768, height: 1024},
  {id: 'ipad-pro', name: 'iPad Pro', width: 1024, height: 1366},
];


class Device extends View
  @content: (device)->
    @li click: 'click', device.name

  initialize: (device)->
    @device = device

  click: ->
    @parentView.click(@device)

module.exports =
class DropdownDevices extends View
  @content: ->
    @div class: 'dropdown-devices', =>
      @ul =>
        for device in devices
          @subview device.id, new Device(device)

  initialize: ->
    @me = this
    $(document).ready =>
      top = $('.ionic-preview .header').offsetHeight
      @me.css('top', top)

  open: =>
    @me.addClass('active')

  close: =>
    @me.removeClass('active')

  toggle: =>
    @me.toggleClass('active')

  click: (device)->
    @parentView.changeDeviceView(device)
