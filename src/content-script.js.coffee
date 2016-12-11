EVIL_THRESHOLD = 30
WARNING_THRESHOLD = 70

popupMessages =
  evil: "This appears to be highly suspicions for the following reasons:"
  warning: "This appears to be highly suspicions for the following reasons:"
  noopinion: "We have not identified this as false.  Here is what we know:"

popupIcons =
  evil: "fa-exclamation-triangle"
  warning: "fa-exclamation-triangle"
  noopinion: "fa-info"

closePopup = ->
  $('#fact_back_popover').remove()

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

formatPopoverMessages = (tone, messages)->
  """
  <strong>#{popupMessages[tone]}</strong>
  <ul>
    #{formatMessageItems(messages)}
  </ul>
  """

openPopover = (button, tone, messages)->
  closePopup()
  message = formatPopoverMessages(tone, messages)
  buttonOffset = button.offset()
  popover = $('body').find('#fact_back_popover')
  if popover.length == 0
    $('body').append($("""
      <div class="fact-back-popover #{tone}" id="fact_back_popover">
      </div>
    """))
    popover = $('body').find('#fact_back_popover')

  popover.html(message).css(
    top: "#{buttonOffset.top + 25}px"
    left: "#{buttonOffset.left}px"
  )

buttonScore = (tone, data)->
  return '' if tone == 'noopinion'
  "<span class=\"fact-back-score\">#{data.ai.score}</span>"

buttonIcon = (tone)->
  "<i class=\"fa #{popupIcons[tone]}\"></i>"

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

        overlay = $("""
          <div class="fact-back-overlay">
          </div>
        """)

        imgSrc = undefined
        if data.ai.score <= EVIL_THRESHOLD
          tone = 'evil'
        else if data.ai.score <= WARNING_THRESHOLD
          tone = 'warning'
        else
          tone = 'noopinion'

        overlay.addClass(tone)

        button = $("""
          <button>
            #{buttonIcon(tone)}
            #{buttonScore(tone, data)}
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
            tone
            data.ai.messages
          )

httpGet = (url, ai = 'true') ->
  # fetch("https://localhost:3001/evaluate?ai=#{ai}&url=#{url}")
  new Promise((resolve, reject)->
    resolve(
      success: true
      ai:
        score: _.random(0, 100)
        messages: ['George Soros', 'Disclaimer']
    )
  )

$(document).ready checkFeed
setInterval checkFeed, 1000
$('body').on('click', closePopup)
