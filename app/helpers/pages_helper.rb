module PagesHelper
  def current_page
    controller.current_page
  end

  def page_title(page)
    page ||= @page
    t = (page.meta && page.meta['title'])
    unless t
      t = page.url
    end
    t
  end
end
