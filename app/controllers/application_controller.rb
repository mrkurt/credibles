class ApplicationController < ActionController::Base
  protect_from_forgery

  def require_account!
    raise "You must supply an account id" if current_account.nil?
  end

  def current_account
    return @current_account if @current_account

    unless params[:account_id].blank?
      @current_account = Account.where(:key => params[:account_id]).first
    end
    @current_account
  end

  def require_page!
    require_account! #can't have a page without it!
    raise "You must supply either a page key or a URL" if current_page.nil?
  end

  def current_page
    return @current_page if @current_page
    return @current_page = Page.find(params[:page_id]) if params[:page_id]
    return nil unless current_account
    return nil unless (params[:page] && !params[:page][:key].blank?) || params[:url]
    key = (params[:page] && !params[:page][:key].blank?) ? params[:page][:key] : Digest::MD5.hexdigest(params[:url])

    @current_page = Page.find_or_create(current_account, key, params[:url])
  end
end
