EVIL_THRESHOLD = 30
WARNING_THRESHOLD = 70
POPOVER_PREAMBLE_EVIL = "This appears to be highly suspicions for the following reasons"
POPOVER_PREAMBLE_WARNING = "This appears to be highly suspicions for the following reasons"

parseQueryString = (href)=>
  # console.log("PARSING = #{href}")
  params = {}
  urlParts = href.split('?')
  return unless urlParts.length > 1
  queryParts = urlParts[1].split('&')
  _.each queryParts, (part, i)->
    nameVal = part.split('=')
    params[nameVal[0]] = decodeURIComponent(nameVal[1])

  # console.log("PARAMS = #{JSON.stringify(params)}")
  params

pullUrlFromHref = (href)->
  params = parseQueryString(href)
  return unless params?

  params['u']

formatMessageItems = (messages)->
  _.map(messages, (message)->
    "<li>#{message}</li>"
  ).join('')

formatPopoverMessages = (preamble, messages)->
  """
  <strong>#{preamble}:</strong>
  <ul>
    #{formatMessageItems(messages)}
  </ul>
  """

openPopover = (button, message)->
  buttonOffset = button.offset()
  popover = $('body').find('#fact_back_popover')
  if popover.length == 0
    $('body').append($("""
      <div class="fact-back-popover" id="fact_back_popover">
      </div>
    """))
    popover = $('body').find('#fact_back_popover')

  popover.html(message).css(
    top: "#{buttonOffset.top + 30}px"
    left: "#{buttonOffset.left}px"
  )

checkFeed = ->
  $('.userContentWrapper .mtm .lfloat a[href][target="_blank"]').each ->
    anchor = $(this)
    container = anchor.parents('.userContentWrapper')

    if !container.data('factBacked')
      container.data('factBacked', true)
      url = pullUrlFromHref($(this).attr('href'))

      return unless url

      httpGet(url)
      .then (data)->
        return unless data.success
        return unless data.ai.score <= WARNING_THRESHOLD

        overlay = $("""
          <div class="fact-back-overlay">
          </div>
        """)

        imgSrc = undefined
        if data.ai.score <= EVIL_THRESHOLD
          imgSrc = "/error.png"
          overlay.addClass('fact-back-evil')
          preamble = POPOVER_PREAMBLE_EVIL
        else
          imgSrc = "/warning.png"
          preamble = POPOVER_PREAMBLE_WARNING

        button = $("""
          <button>
            <img src="#{chrome.extension.getURL(imgSrc)}">
            <span class="fact-back-score">#{data.ai.score}</span>
          </button>
        """)
        overlay.append(button)
        anchor
        .parents('.lfloat')
        .append(overlay)
        .find('button')
        .click (event)->
          event.stopPropagation()
          openPopover(
            $(this)
            formatPopoverMessages(
              preamble
              data.ai.messages
            )
          )

httpGet = (url, ai = 'true') ->
  console.log("GET #{url}")
  # fetch("https://localhost:3001/evaluate?ai=#{ai}&url=#{url}")
  new Promise((resolve, reject)->
    resolve(
      success: true
      ai:
        score: 20
        messages: ['George Soros', 'Disclaimer']
    )
  )

$(document).ready checkFeed
setInterval checkFeed, 1000
$('body').on('click', ->
  $('#fact_back_popover').remove()
)
