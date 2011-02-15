class EditsController < ApplicationController
  before_filter :require_page!, :only => ['new', 'create']
  def new
    @edit = current_account.edits.new(params[:edit])
    @edit.suggestions << Edit::Suggestion.new(params[:suggestion])
    render :layout => 'framed'
  end

  def create
    @edit = current_account.edits.new(params[:edit])
    @edit.ip_address = request.remote_ip
    @edit.add_suggestions(params[:suggestion])

    if @edit.save
      redirect_to @edit
    else
      @errors = @edit.errors
      render :new, :layout => 'framed'
    end
  end

  def show
    @edit = Edit.find(params[:id])
    render :layout => 'framed'
  end

end
