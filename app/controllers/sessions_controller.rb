class SessionsController < ApplicationController
  def new
    key = params[:key].to_s
    @account = Account.find_by_editor_token(key)

    if @account.nil?
      render :status => 403, :text => 'no yuo!'
    else
      session["account_key_#{@account.id}"] = key
      url = params[:url] || '/'
      redirect_to url
    end
  end
end
