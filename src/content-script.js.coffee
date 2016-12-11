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

fetchCache = {}

closePopup = ->
  $('#fact_back_popover').remove()

updateUrlParams = (e) ->
    if (e.key == 'storage-event')
        output.innerHTML = e.newValue;


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

formatReference = (reason)->
  return ''
  """
    <a class="info" href="#{reason.reference}" target="_blank">
      <i class="fa fa-info"></i>
    </a>
  """

formatAuthor = (reason)->
  return ''
  """
  &nbsp;(#{reason.author})
  """

formatReason = (reason)->
  """
  <li>
    #{reason.body}
    #{formatAuthor(reason)}
    #{formatReference(reason)}
  </li>
  """

formatReasons = (reasons)->
  _.map(reasons, (reason)->
    formatReason(reason)
  ).join('')

formatPopover = (tone, messages)->
  """
  <strong>#{popupMessages[tone]}</strong>
  <ul>
    #{formatReasons(messages)}
  </ul>
  """

openPopover = (button, tone, messages)->
  closePopup()
  message = formatPopover(tone, messages)
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
  "<span class=\"fact-back-score\">#{data.score}</span>"

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
        .click (event)->
          event.stopPropagation()
          openPopover(
            $(this)
            tone
            data.reasons
          )

cachedGet = (url, ai = 'true')->
  if fetchCache[url]
    Promise.resolve(fetchCache[url])
  else
    httpGet(url, ai)
    .then (data)->
      fetchCache[url] = data
      data

httpGet = (url, ai = 'true') ->
  console.log("httpGet #{url}")

  # fetch("https://localhost:3001/evaluate?ai=#{ai}&url=#{url}")
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
window.addEventListener("storage", checkFeed, true);
$('body').on('click', closePopup)
