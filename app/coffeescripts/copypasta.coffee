w = window
return unless w.postMessage

append_to_element = (e for e in document.documentElement.childNodes when e.nodeType == 1)[0]
iframe_host = "http://localhost:3000"
static_host = "http://localhost:3000"
css = document.createElement('link')
css.rel = "stylesheet"
css.href = static_host + "/stylesheets/compiled/copypasta.css?v=2"
append_to_element.appendChild(css)

$ = false
currentLive = false
currentContainer = false
form_data = {}

w.copypasta = copypasta = {$ : false, page_id : w.copypasta_page_id}
copypasta.account_id = w.copypasta_account_id
copypasta.debug = w.copypasta_debug || w.location.hash.indexOf('copypasta-debug') > 0
copypasta.auto_start = w.copypasta_auto_start || w.location.hash.indexOf('copypasta-auto') > 0
copypasta.include_url_hash = w.copypasta_include_url_hash
copypasta.content_selector = w.copypasta_content_selector
copypasta.paragraph_threshold = w.copypasta_paragraph_threshold || 3
copypasta.character_threshold = w.copypasta_character_threshold || 100

copypasta.locate_text_containers = locate_text_containers = ()->
  containers = []
  parent = false
  parent_count = 0
  parent_character_count = 0

  for p in $('p')
    p = $(p)
    if parent != p.parent().get(0)
      if parent_count >= copypasta.paragraph_threshold || parent_character_count > copypasta.character_threshold
        containers.push(parent)
      parent = p.parent().get(0)
      parent_count = 0
      parent_character_count = p.text().length

    parent_count += 1
    parent_character_count += p.text().length

  if parent_count >= copypasta.paragraph_threshold || parent_character_count > copypasta.character_threshold
    containers.push(parent)

  containers

debug_msg = (msg)->
  if copypasta.debug
    if console && console.log
      console.log(msg)

ids =
  indicator: 'copy-pasta-edit-indicator'
  dialog: 'copy-pasta-dialog'
  iframe : 'copy-pasta-iframe'
  btn: 'copy-pasta-button'
  widget: 'copy-pasta-widget'

paths =
  indicator: '#' + ids.indicator
  dialog: '#' + ids.dialog
  btn: '#copypasta-button, #copy-pasta-button, .copy-pasta-button'
  active: '.copy-pasta-active'
  iframe: '#' + ids.iframe
  overlay: '.copy-pasta-overlay'
  status: '#copy-pasta-button .status'
  widget: '#' + ids.widget
  widget_iframe: '#' + ids.widget + ' iframe'


indicator = () ->
  if $(paths.indicator).length == 0
    $('body').append('<div id="' + ids.indicator + '"><p>click to correct</p></div>')
    $(paths.indicator).bind('mouseout', deactivate)
    $(paths.indicator).bind('click', show_edit_dialog)

  $(paths.indicator)

overlay = (el) ->
  if $(el).prev(paths.overlay).length == 0
    $(el).before('<div class="copy-pasta-overlay"></div>')

  $(el).prev(paths.overlay)

cover = (target, element)->
  sz =
    width: $(target).outerWidth() + 'px'
    height: $(target).outerHeight() + 'px'

  element ||= overlay(target).fadeIn()

  $(element).css(sz)

find_current_url = ()->
  oh = w.location.hash
  if copypasta.include_url_hash
    w.location.hash = w.location.hash.replace(/#?copypasta-[a-z]+/g,'')
  else
    w.location.hash = ''

  url = ($('link[rel=canonical]').attr('href') || w.location.href.replace(/#+$/,''))
  a = w.document.createElement('a')
  a.href = url
  url = a.href #resolves relative URLs
  w.location.hash = oh
  url

#dialog stuff
blank_dialog = (class_name) -> '<div id="' + ids.dialog + '" class="' + class_name + '"><iframe frameborder="no" id="' + ids.iframe + '" scrolling="no"></iframe></div>'

resize = (path, data)->
  $(path).animate {height : data.h}

show_edit_dialog = ()->
  e = currentLive
  e.original_text ?= e.innerHTML

  page_id = copypasta.page_id ? ''
  account_id = copypasta.account_id ? ''
  form_data.new_edit =
    'edit[original]' : e.original_text
    'edit[proposed]' : e.original_text
    'edit[url]' : find_current_url()
    'edit[element_path]' : copypasta.getElementCssPath(e)
  
  url = iframe_host + '/edits/new?view=framed&url=' + escape(find_current_url()) + '&page[key]=' + escape(page_id) + '&account_id=' + account_id

  $(paths.widget).hide()
  show_dialog(url, 'edit')

dialog_types =
  default:
    options: { escClose: true, overlayClose: true, overlayId : 'copy-pasta-lightbox-overlay', containerId : 'copy-pasta-lightbox-container', opacity: 70, persist: true}
  edit:
    class: 'copy-pasta-lightbox'

show_dialog = (src, type) ->
  copypasta.modal_init($) unless $.fn.modal

  if $.modal && $('#copy-pasta-lightbox-container').length > 0
    $.modal.close()
    setTimeout (()-> show_dialog(src,type)), 11 #modal closes async in 10ms
  else
    t = dialog_types.default
    t.options.onShow = ()->
      if src
        cover paths.iframe
        debug_msg("Overlay shown")
        src = src
        src += '#debug' if copypasta.debug
        debug_msg("Loading iframe: " + src)
        $(paths.iframe).attr('src', src)

    if type && dialog_types[type]
      t = dialog_types[type]
      t.options = {} unless t.options
      t.options = $.extend(t.options, dialog_types.default.options) unless t.extended
      t.extended = true

    $.modal(blank_dialog(t.class), t.options)
#dialog-end

#widget stuff
widget_url = ()->
  page_id = copypasta.page_id ? ''
  account_id = copypasta.account_id ? ''
  url = iframe_host + '/edits?view=framed&url=' + escape(find_current_url()) + '&page[key]=' + escape(page_id) + '&account_id=' + account_id

blank_widget = '<div id="' + ids.widget + '"><h1><a href="https://copypasta.credibl.es"><img src="' + static_host + '/images/logo-small.png" /></a></h1><iframe frameborder="no" scrolling="no"></iframe></div>'

widget = (src)->
  if $(paths.widget).length == 0
    $('body').append(blank_widget)
    unless src?
      src = widget_url()

  if src?
    iframe = $(paths.widget).find('iframe').attr('src', src)
    cover iframe
  $(paths.widget).show()
#widget-end

show_edit_preview = (data)->
  debug_msg('Previewing ' + data.element_path)
  target = $(data.element_path)
  pos = target.position()
  unless target.get(0).original_text
    target.get(0).original_text = target.html()
  s = if $('html').scrollTop(1) > 0 then 'html' else 'body'
  $(s).animate {scrollTop : pos.top}, ()->
    target.html(data.proposed).addClass('copy-pasta-preview')

hide_edit_preview = (path)->
  target = $(path)
  target.removeClass('copy-pasta-preview').html(target.get(0).original_text)

hide_edit_previews = ()->
  $('.copy-pasta-preview').each ()->
    o = this.original_text ? $(this).html()
    $(this).removeClass('copy-pasta-preview').html(o)

is_scrolled_into_view = (elem)->
    docViewTop = $(window).scrollTop()
    docViewBottom = docViewTop + $(window).height()

    elemTop = $(elem).offset().top
    elemBottom = elemTop + $(elem).height()

    (elemBottom >= docViewTop) && (elemTop <= docViewBottom)&& (elemBottom <= docViewBottom) &&  (elemTop >= docViewTop)

load_iframe_form = (id)->
  if id && form_data[id]
    send_to_iframe('label' : 'form_data', 'data' : form_data[id])
    form_data[id] = false

send_to_iframe = (msg) ->
  debug_msg("Parent send: " + msg.label + " to " + iframe_host)
  msg = JSON.stringify(msg)
  $(paths.iframe).get(0).contentWindow.postMessage(msg, iframe_host)

receive_from_iframe = (e) ->
  unless e.origin == iframe_host
    debug_msg(e)
    return
  data = JSON.parse(e.data)
  debug_msg("Parent receive: " + data.label + " from " + e.origin + ' for frame type: ' + data.frame_type)

  if data.frame_type == 'dialog'
    handle_dialog_message(data)
  else
    handle_widget_message(data)

handle_widget_message = (data)->
  if data.label == 'ready'
    overlay(paths.widget_iframe).fadeOut()
  else if data.label == 'loading'
    cover paths.widget_iframe
  else if data.label == 'resize'
    resize(paths.widget + ' iframe', data)
  else if data.label == 'finished'
    end_editing()
  else if data.label == 'preview'
    show_edit_preview(data)
  else if data.label == 'preview-off'
    hide_edit_preview(data.element_path)

handle_dialog_message = (data)->
  if data.label == 'ready'
    unless load_iframe_form(data.form_id)
      #have to wait til after form data postMessage, otherwise
      overlay(paths.iframe).fadeOut()
  else if data.label == 'form_data_loaded'
    overlay(paths.iframe).fadeOut()
  else if data.label == 'finished'
    $.modal.close() if $.modal
    hide_edit_previews()
    widget().show()
    if data.reload_widget
      cover paths.widget_iframe
      $(paths.widget_iframe).attr('src', $(paths.widget_iframe).attr('src'))
  else if data.label == 'resize'
    resize(paths.dialog, data)

editable_elements = 'p, h1, h2, h3, h4, h5, td, th, li'

editable_click = (e)->
  if e not instanceof HTMLAnchorElement
    currentLive = this
    show_edit_dialog()
    return false

copypasta.start_editing = start_editing = ()->
  images.load()
  $(paths.btn).addClass('on')
  elements = $(currentContainer).addClass('copy-pasta-active').find(editable_elements).filter(':visible').filter (i)->
    $.trim($(this).text()) != ''
  debug_msg "Found #{elements.length} editable elements"
  #handle containers
  #$.merge(elements, $(currentContainer).children(editable_element_containers).find(editable_elements))

  elements.addClass('copy-pasta-editable').bind('click', editable_click)
  widget()

end_editing = ()->
  $(paths.btn).removeClass('on')
  hide_edit_previews()
  $(currentContainer).removeClass('copy-pasta-active')
  $('.copy-pasta-editable').removeClass('copy-pasta-editable').unbind('click', editable_click)
  widget().remove()

init = ()->
  return unless window.JSON && window.postMessage #bails out of IE if not standards mode >= ie8
  if copypasta.content_selector
    currentContainer = $(copypasta.content_selector)
  else
    currentContainer = $(locate_text_containers())

  $(paths.btn).show().bind 'click', ()->
    if $(this).hasClass('on')
      end_editing()
    else
      start_editing()

  if w.addEventListener
    w.addEventListener('message', receive_from_iframe, false)
  else if w.attachEvent
    w.attachEvent('onmessage', ()-> receive_from_iframe(event))

  if copypasta.auto_start
    start_editing()


scripts = [
    {
      test: ()->
        if w.jQuery && w.jQuery.fn && w.jQuery.fn.jquery > "1.3"
          copypasta.$ = $ = w.jQuery
          debug_msg("Using existing jquery: version " + $.fn.jquery)
          true
      #src: 'http://localhost:3000/javascripts/jquery-1.3.min.js'
      src: 'http://localhost:3000/javascripts/jquery-1.4.4.min.js'
      callback : ()->
        (copypasta.$ = $ = w.jQuery).noConflict(1)
        debug_msg("Loaded own jquery: version " + $.fn.jquery)
    },
    {
      test: ()-> copypasta.getElementCssPath && w.jQuery && w.jQuery.fn.lightbox_me
      src: 'http://localhost:3000/javascripts/utils.min.js'
    }
]

scripts.load = (queue, callback) ->
  remaining = (i for i in queue when !i.state)
  return if remaining.length == 0
  def = remaining.pop()
  def.state = 'pending'
  s = document.createElement('script')
  s.type = "text/javascript"
  s.src = def.src
  s.onload = s.onreadystatechange = ()->
    d = this.readyState
    if def.state != 'loaded' && (!d || d == 'loaded' || d == 'complete')
      def.state = 'loaded'
      def.callback() if def.callback
      remaining = (i for i in queue when i.state != 'loaded')
      if remaining.length == 0
        callback()
  scripts.load(queue, callback) if queue.length > 0
  append_to_element.appendChild(s)

images = [
  "translucent-blue.png",
  "translucent-black.png",
  "translucent-black-85.png",
  "loading.gif"
  "pencil.png"
  "logo-small.png"
]
images.load = ()->
  for i in images
    img = new Image
    img.src = static_host + '/images/' + i

queue = (s for s in scripts when s && !s.test())

if queue.length > 0
  scripts.load(queue, init)
else
  init()
