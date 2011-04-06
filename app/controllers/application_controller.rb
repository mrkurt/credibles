class ApplicationController < ActionController::Base
  protect_from_forgery

  def require_account!
    raise "You must supply an account id" if current_account.nil?
  end

  def editor_for?(acct_or_obj)
    a = a.account_id if a.respond_to?(:account_id)
    a = acct_or_obj.id unless a

    user_accounts.detect{|ua| ua.id = a}
  end

  def user_accounts
    return @user_accounts if @user_accounts
    keys = session.keys.map do |k|
      if k =~ /account_key_\w+/
        session[k]
      else
        nil
      end
    end.reject(&:nil?)

    return [] if keys.length == 0

    ids = EditorToken.where(:key.in => keys).map(&:account_id)
    @user_accounts = Account.where(:_id.in => ids).to_a
  end

  def current_account
    return @current_account if @current_account
    params = safe_params

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

    @current_page = Page.find_or_create(current_account, key, params[:url])
  end

  def safe_params
    @safe_params ||= Hash[*(params.map{|k,v| [k,v.to_s]}.flatten)]
  end
end
