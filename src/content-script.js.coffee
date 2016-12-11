EVIL_THRESHOLD = 30
WARNING_THRESHOLD = 70
API_HOST = "https://news-hound-api.herokuapp.com"

strings =
  popupMessages:
    evil: "This appears to be highly suspicions for the following reasons:"
    warning: "This appears to be highly suspicions for the following reasons:"
    noopinion: "We have not identified this as false.  Here is what we know:"
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

formatReasons = (reasons)->
  _.map(reasons, (reason)->
    formatReason(reason)
  ).join('')

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
  <ul>
    #{formatReasons(reasons)}
  </ul>
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

apiUrl = (href, ai = 'true')->
  return unless href?
  "/evaluate?ai=#{ai}&url=#{href}"

checkFeed = ->
  $('.userContentWrapper .mtm .lfloat a[href][target="_blank"]').each ->
    anchor = $(this)
    container = anchor.parents('.userContentWrapper')

    if !container.data('factBacked')
      container.data('factBacked', true)
      url = apiUrl(pullUrlFromHref($(this).attr('href')))

      return unless url?

      console.log("checking for set presents mode now...")

      if localStorage.getItem('ai')
        console.log(localStorage.getItem('ai'))
      else
        console.log("Oops.. not AI found")

      console.log("local storage done.")

      cachedGet(url)
      .then (data)->
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
            data.reasons
          )

cachedGet = (url)->
  if fetchCache[url]
    Promise.resolve(fetchCache[url])
  else
    httpGet(url)
    .then (data)->
      fetchCache[url] = data
      data

httpGet = (url) ->
  console.log("httpGet #{url}")

  # fetch(url)
  Promise.resolve(
    success: true
    score: _.random(0, 100)
    reasons: [
      body: 'Not scientifically accurate'
      author: 'Monte'
      reference: 'http://www.scientificamerican.com/'
    ,
      body: 'This domain has been blacklisted by Snopes'
      author: 'Snopes'
      reference: 'http://www.snopes.com'
    ]
  )

$(document).ready checkFeed
setInterval checkFeed, 1000
window.addEventListener("storage", checkFeed, true)
$('body').on('mouseover', closePopup)
