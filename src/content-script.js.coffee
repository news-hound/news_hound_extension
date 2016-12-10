checkFeed = ->
  $('.userContentWrapper .lfloat a[href][target="_blank"]').each ->
    if $(this).parents('.userContentWrapper').find('.fact-back-overlay').length == 0
      $(this).parents('.lfloat').append("""
        <div class="fact-back-overlay">
        </div>
      """)

$(document).ready checkFeed
setInterval checkFeed, 1000
