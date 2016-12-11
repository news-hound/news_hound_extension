EVIL_THRESHOLD = 30
WARNING_THRESHOLD = 80
API_HOST = "https://news-hound-api.herokuapp.com"
SETTINGS = [
  'newshound'
  'snopes'
  'real_or_satire'
  'politifact'
]

strings =
  popupMessages:
    evil: "This appears to be highly suspicions for the following reasons:"
    warning: "This appears to be highly suspicions for the following reasons:"
    noopinion: "We have not yet identified this as false."
  commentPrompt: 'Maybe add a comment? How about starting with...'

popupIcons =
  evil: "fa-exclamation-triangle"
  warning: "fa-exclamation-triangle"
  noopinion: "fa-info"

fetchCache = {}

closePopup = ->
  $('#fact_back_popover').remove()

updateUrlParams = (e) ->
  if (e.key == 'storage-event')
    output.innerHTML = e.newValue

parseQueryString = (href)->
  params = {}
  urlParts = href.split('?')
  return unless urlParts.length > 1
  queryParts = urlParts[1].split('&')
  _.each queryParts, (part, i)->
    nameVal = part.split('=')
    params[nameVal[0]] = decodeURIComponent(nameVal[1])

  params

pullUrlFromHref = (href)->
  params = parseQueryString(href)
  return unless params?

  params['u']

formatAuthor = (reason)->
  return '' unless reason.author?
  """
  &nbsp;(#{reason.author})
  """

formatReference = (reason)->
  return '' unless reason.reference?
  """
    <a href="#{reason.reference}" target="_blank">
      <i class="fa fa-info-circle"></i>
    </a>
  """

formatReason = (reason)->
  """
  <li>
    <div class="media">
      <div class="media-left">
        <i class="fa fa-circle"></i>
      </div>
      <div class="media-body">
        #{reason.body}
        #{formatAuthor(reason)}
      </div>
      <div class="media-right">
        #{formatReference(reason)}
      </div>
    </div>
  </li>
  """

formatReasons = (tone, reasons)->
  return '' if tone == 'noopinion'
  items = _.map(reasons, (reason)->
    formatReason(reason)
  ).join('')
  """
  <ul>
    #{items}
  </ul>
  """

formatShareText = (tone, reasons)->
  reasons = _.map(reasons, 'body').join(', ')
  "#{strings.popupMessages[tone]} #{reasons}"

formatShareFrame = (tone, reasons)->
  return '' if tone == 'noopinion'
  """
  <div class="fact-back-share-frame">
    <strong>#{strings.commentPrompt}</strong>
    <div>
      <textarea readonly>#{formatShareText(tone, reasons)}</textarea>
    </div>
  </div>
  """

formatPopoverContent = (tone, reasons)->
  """
  <strong>#{strings.popupMessages[tone]}</strong>
  #{formatReasons(tone, reasons)}
  #{formatShareFrame(tone, reasons)}
  """

openPopover = (button, tone, reasons)->
  closePopup()
  buttonOffset = button.offset()
  popover = $("""
    <div class="fact-back-popover" id="fact_back_popover">
    </div>
  """)
  popover.html(
    formatPopoverContent(tone, reasons)
  ).css(
    top: "#{buttonOffset.top + 25}px"
    left: "#{buttonOffset.left}px"
  ).addClass(tone)
  $('body').append(popover)
  $('#fact_back_popover').mouseover((event)-> event.stopPropagation())

buttonScore = (tone, data)->
  return '' if tone == 'noopinion'
  "<span class=\"fact-back-score\">#{data.score}</span>"

buttonIcon = (tone)->
  "<i class=\"fa #{popupIcons[tone]}\"></i>"

fetchApiUrl = (href, fn)->
  chrome.storage.sync.get SETTINGS, (items) ->
    ai = items['newshound']
    lenses = _.compact(
      _.map(
        _.slice(SETTINGS, 1)
        (setting, i)->
          "lenses[]=#{i+2}" if items[setting]
      )
    ).join('&')

    fn("#{API_HOST}/evaluate?ai=#{ai}&url=#{href}&#{lenses}")

checkFeed = ->
  $('.userContentWrapper .mtm .lfloat a[href][target="_blank"]').each ->
    anchor = $(this)
    container = anchor.parents('.userContentWrapper')

    if !container.data('factBacked')
      container.data('factBacked', true)
      console.log("Fetching the params now...")
      fetchApiUrl pullUrlFromHref($(this).attr('href')), (url)->

        return unless url?

        cachedGet(url)
        .then (data)->
          console.log "DATA: #{JSON.stringify(data)}"
          return unless data.success

          overlay = $("""
            <div class="fact-back-overlay">
            </div>
          """)

          imgSrc = undefined
          if data.score <= EVIL_THRESHOLD
            tone = 'evil'
          else if data.score <= WARNING_THRESHOLD
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
          .mouseover (event)->
            event.stopPropagation()
            openPopover(
              $(this)
              tone
              data.messages
            )
        .catch (error)->
          console.log("ERROR #{error}")

cachedGet = (url)->
  if fetchCache[url]
    Promise.resolve(fetchCache[url])
  else
    httpGet(url)
    .then (response)->
      console.log("RESPONSE: #{response}")
      response.json()
    .then (data)->
      console.log("DATA: #{JSON.stringify(data)}")
      fetchCache[url] = data
      Promise.resolve(data)

httpGet = (url) ->
  console.log("httpGet #{url}")

  fetch(url)
  # Promise.resolve(
  #   success: true
  #   score: _.random(0, 100)
  #   reasons: [
  #     body: 'Not scientifically accurate'
  #     author: 'Monte'
  #     reference: 'http://www.scientificamerican.com/'
  #   ,
  #     body: 'This domain has been blacklisted by Snopes'
  #     author: 'Snopes'
  #     reference: 'http://www.snopes.com'
  #   ]
  # )

$(document).ready checkFeed
setInterval checkFeed, 1000
window.addEventListener("storage", checkFeed, true)
$('body').on('mouseover', closePopup)
