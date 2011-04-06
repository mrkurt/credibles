xhr_error = (xhr, status)->
  console.error status

edit_submit = (form)->
  d = $(form).serialize()
  action = form.action + '.json'
  xhr = $.post(action, d, edit_row_result).error(xhr_error)

edit_row_submit = ()->
  edit_submit(this)
  $(this).closest('tr').addClass('loading').find('input,form,select').attr('disabled', 'disabled')
  return false

edit_row_result = (data, textStatus)->
  switch data.type
    when 'update' then edit_row_replace(data.html)
    when 'edit' then edit_row_notes(data.html)

edit_row_notes = (html)->
  c = content_overlay().show()
  d = dialog().show()
  d.html(html)

  $(d).find('form').bind 'submit', ()->
    edit_submit(this)
    d.hide()
    c.hide()
    return false


edit_row_replace = (html)->
  id = $(html).attr('id')
  $('#' + id).replaceWith(html)

auto_submit = ()->
  f = $(this).closest('form')
  f.submit()
  console.debug 'submitting'

content_overlay = ()->
  o = $('#container > .overlay')
  if o.length == 0
    $('#container').append('<div class="overlay"></div>')
    o = $('#container > .overlay')

  o

dialog = ()->
  o = $('#dialog')
  if o.length == 0
    $('#container').append('<div id="dialog"></div>')
    o = $('#dialog')

  o

$('input.auto').live 'change', auto_submit
$('input#select-all-edits').live 'change', ()->
  c = $(this).is(':checked')
  $('input.edit-selector').attr('checked', c)

$('form.edit-row.embed').live 'submit', edit_row_submit
