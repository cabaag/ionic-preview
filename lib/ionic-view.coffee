{$, ScrollView, View} = require 'atom'
module.exports =
class WebBrowserPreview extends View
   @content: (params) ->
      @div =>
         @h1 'Hola'
         @iframe name:"frame", class: "iphone", src: params.url, sandbox: "allow-same-origin allow-scripts"

   getTitle: ->
      "Ionic: Preview"

   initialize: (params) ->
      me = $(@)
      frame = me.children("[name='frame']")
      console.log(frame)
      @url = params.url
      me.load ->
         $(window).resize ->
            height = frame.parentNode?.scrollHeight
            if height < frame.height()
               frame.css("transform", "scale(" + ((height - 50) / frame.height()) + ")")
            else
               frame.css("transform", "none")

   go: ->
      me = $(@)
      @.src = @url
      frame = me.children("[name='frame']")
      height = frame[0].parentNode?.scrollHeight
      if height? and height < me.height()
         frame.css("transform", "scale(" + ((height - 50) / frame.height()) + ")")
      else
         frame.css("transform", "none")
      frame.css("display", "block")
