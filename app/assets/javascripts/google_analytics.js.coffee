@h ||= {}
@h.ga_init = (code) ->
  window._gaq = [] if !window._gaq?
  _gaq = window._gaq
  _gaq.push(['_setAccount', code])
  _gaq.push(['_trackPageview'])
  (->
    ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    gajs = '.google-analytics.com/ga.js'
    ga.src = if 'https:' is document.location.protocol then 'https://ssl'+gajs else 'http://www'+gajs
    s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s)
  )()

@h.ga_track = (category, action, label = null, value = null) ->
  window._gaq = [] if !window._gaq?
  _gaq = window._gaq
  _gaq.push(['_trackEvent', category, action, label, value])

$(document).ready -> h.ga_init('UA-42851166-1')
