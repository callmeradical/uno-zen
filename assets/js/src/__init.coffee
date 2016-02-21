'use strict'

window.Uno = Uno =
  version: '2.7.3'
  app: do -> document.body
  is: (k, v=!'undefined') -> this.app.dataset[k] is v

  context: ->
    # get the context from the first class name of body
    # https://github.com/TryGhost/Ghost/wiki/Context-aware-Filters-and-Helpers
    className = document.body.className.split(' ')[0].split('-')[0]
    if className is '' then 'error' else className

  search:
    container: -> $('#results')
    form: (action) -> $('#search-container')[action]()

  loadingBar: (action) -> $('.pace')[action]()

  timeAgo: (selector) ->
    $(selector).each ->
      postDate = $(this).html()
      postDateInDays = Math.floor((Date.now() - new Date(postDate)) / 86400000)

      if postDateInDays is 0 then postDateInDays = 'today'
      else if postDateInDays is 1 then postDateInDays = 'yesterday'
      else postDateInDays = "#{postDateInDays} days ago"

      $(this).html(postDateInDays)
      $(this).mouseover -> $(this).html postDate
      $(this).mouseout -> $(this).html postDateInDays

  ###*
   * Apply Infinite scroll to a Ghost view.
   * @param  {Object}  opts
   * @param  {Integer} opts.page             Current page count.
   * @param  {Integer} opts.maxPage          Max page count.
   * @param  {Integer} opts.heigthSelector   Selector used to calculate height offset.
   * @param  {Array}   opts.childrenSelector Selector for the AJAX action.
   *
   * @return {[type]}      [description]
  ###
  infiniteScroll: (opts) ->
    return unless window.infinite_scroll

    threshold = 0.25
    url = window.location.origin + opts.page
    isFetching = false
    existsPagesToFetch = -> opts.currentPage < opts.maxPage
    nextPage = -> "#{url}/#{++opts.currentPage}"

    $(window).scroll ->
      scrollPosition = $(window).scrollTop()
      height = $(opts.heigthSelector)[0].offsetHeight
      height = height - (height * threshold)
      isNearToBottom = scrollPosition > height

      if existsPagesToFetch() and isNearToBottom and !isFetching
        isFetching = true
        $.get nextPage(), (data) ->
          data = $(data)
          data = data.children(selector) for selector in opts.childrenSelector
          $(opts.heigthSelector).append data
          isFetching = false

  device: ->
    w = window.innerWidth
    h = window.innerHeight
    return 'mobile' if (w <= 480)
    return 'tablet' if (w <= 1024)
    'desktop'

Uno.app.dataset.page = Uno.context()
Uno.app.dataset.device = Uno.device()

# window global properties

## defaults
window.open_button ?= '.nav-posts > a'
window.infinite_scroll ?= true

$('#profile-title').text window.profile_title if window.profile_title
$('#profile-resume').text window.profile_resume if window.profile_resume

unless window.posts_headline
  $('#posts-headline').hide()
else
  $('#posts-headline').text window.posts_headline if window.posts_headline

$('.pagination').hide() unless window.infinite_scroll
