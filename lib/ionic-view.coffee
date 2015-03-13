{$, ScrollView} = require 'atom'

module.exports =
class WebBrowserPreviewView extends ScrollView
   @content: (params) ->
      @iframe outlet: "frame", class: "iphone", src: params.url, sandbox: "allow-same-origin allow-scripts"
   getTitle: ->
      "Ionic: Preview"
   initialize: (params) ->
      me = $(@)
      @url = params.url
      @.on 'load', ->
         $(window).on 'resize', ->
            height = me[0].parentNode?.scrollHeight
            if height? and height < me.height()
               me.css("transform", "scale(" + ((height - 100) / me.height()) + ")")
            else
               me.css("transform", "none")
   go: ->
      me = $(@)
      @.src = @url
      height = me[0].parentNode?.scrollHeight
      if height? and height < me.height()
         me.css("transform", "scale(" + ((height - 100) / me.height()) + ")")
      else
         me.css("transform", "none")
      me.css("display", "block")
