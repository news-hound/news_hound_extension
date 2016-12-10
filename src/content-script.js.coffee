checkFeed = ->
  $('.userContentWrapper .lfloat a[href][target="_blank"]').each ->
    if $(this).parents('.userContentWrapper').find('.fact-back-overlay').length == 0
      console.log "Yoooooo"
      httpGet("http://www.nytimes.com/2016/12/10/business/dealbook/how-the-twinkie-made-the-super-rich-even-richer.html", $(this))
      $(this).parents('.lfloat').append("""
        <div class="fact-back-overlay">
          Yoooooooooo
        </div>
      """)

httpGet = (url, data) ->
  server = 'https://localhost:3001/evaluate'
  contents = '?ai=true&url='

  link_url = server + contents + url

  fetch(link_url).then (response) ->
    console.log "herer"
    response.json().then (json) ->
      `var score`

      errorImgUrl = chrome.extension.getURL('/public/img/error.png')
      checkedImgUrl = chrome.extension.getURL('/public/img/checked.png')
      warningImgUrl = chrome.extension.getURL('/public/img/warning.png')

      div = document.createElement('div')
      button = Ladda.create(div)
      data.appendChild div

      score = null

      if json['success'] == true
        ai_results = json['ai']
        score = ai_results['score']
        messages = ai_results['messages']
        i = 0
        while i < messages.length
          console.log messages[i]
          i++
        if score >= 90
        else
        div.style = 'font-weight:bold; position:absolute; background:none; top: 4px; right: 30px; font-size: 20px; color: #444;'
      else
        score = Math.floor(Math.random() * 100)
        div.style = 'background-color: #C6C8C2; color: #fff; font-size: 27px; position:absolute; top: 0px; left: 0px; width: 100%; height: 100%; opacity: 0.5;'
      return
  return

$(document).ready checkFeed
setInterval checkFeed, 1000
