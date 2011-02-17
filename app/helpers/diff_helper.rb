module DiffHelper
  def diff(suggestion, escape = true)
    o = suggestion.original
    p = suggestion.proposed
    o = h o if escape
    p = h p if escape
    HTMLDiff.diff(o,p)
  end

  def diff_before(suggestion, escape = true)
    d = diff(suggestion, escape)
    diff_strip_and_collapse(d, 'ins', 'del')
  end
  def diff_after(suggestion, escape = true)
    d = diff(suggestion, escape)
    diff_strip_and_collapse(d, 'del', 'ins')
  end

  def diff_strip_and_collapse(d, strip_tag, collapse_tag)
    d = d
          .gsub(/<#{strip_tag}( class="\w+")?>.*?<\/#{strip_tag}>/, '') #strip
          .gsub(/<\/#{collapse_tag}>\s<#{collapse_tag}( class="\w+")?>/, ' ') #collapse
    HTMLDiff.diff_in_context(d)
  end

  def diff_text(d)
    d
      .gsub(/<\/?ins( class="\w+")?>/, '+')
      .gsub(/<\/?del( class="\w+")?>/, '-')
  end
end
