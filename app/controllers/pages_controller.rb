class PagesController < ApplicationController
  def index
    @accounts = user_accounts
  end
  def show
    @page = Page.find(params[:id])
    @edits = @page.edits
  end
end
