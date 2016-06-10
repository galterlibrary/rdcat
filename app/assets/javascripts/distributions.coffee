# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$('.uri_show').click ->
  $(".distribution_file").hide()
  $(".uri").removeClass('hide').addClass('show')
  $(".artifact").removeClass('show').addClass('hide')
  true

$('.artifact_show').click ->
  $(".distribution_file").hide()
  $(".uri").removeClass('show').addClass('hide')
  $(".artifact").removeClass('hide').addClass('show')
  true

$('.cancel').click ->
  $(".distribution_file").show()
  $(".uri").removeClass('show').addClass('hide')
  $(".artifact").removeClass('show').addClass('hide')
  true 