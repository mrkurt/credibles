module EditsHelper
  def diff_edit(edit = nil, escape = true)
    edit ||= @edit
    o = edit.original
    p = edit.proposed
    o = h o if escape
    p = h p if escape
    HTMLDiff.diff(o, p)
  end

  def diff_edit_context(edit = nil, escape = true)
    edit ||= @edit
    o = edit.original
    p = edit.proposed
    o = h o if escape
    p = h p if escape
    d = HTMLDiff.diff_in_context(o,p)
  end

  def diff_edit_text(d)
    d
      .gsub(/<\/?ins( class="\w+")?>/, '+++')
      .gsub(/<\/?del( class="\w+")?>/, '---')
      .gsub('+++---', '+++ ---')
      .gsub('---+++', '--- +++')
  end
end
