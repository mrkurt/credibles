class EditsController < ApplicationController
  before_filter :require_page!, :only => ['new', 'create']
  def index
    @edits = Edit.all
  end

  def new
    @edit = current_account.edits.new(params[:edit])
    @edit.suggestions << Edit::Suggestion.new(params[:suggestion])
    render :layout => 'framed'
  end

  def create
    @edit = current_page.edits.new(params[:edit])
    @edit.ip_address = request.remote_ip
    @edit.add_suggestions(params[:suggestion])

    if @edit.save
      flash[:success] = "Your edit has been submitted for approval"
      redirect_to @edit
    else
      @errors = @edit.errors
      render :new, :layout => 'framed'
    end
  end

  def update
    @edit = Edit.find(params[:id])
    raise "No yuo!" unless editor_for?(@edit)
    @edit.attributes = params[:edit]
    @edit.reset_editor_notes! if @edit.editor_notes.blank?

    tmpl = 'update'
    if !@edit.changed? || @edit.status == 'accepted' || params[:edit][:editor_notes]
      @edit.save!
    else
      tmpl = 'edit'
    end

    respond_to do |format|
      format.html {
        if tmpl == 'update'
          redirect_to @edit.page
        else
          render tmpl
        end
      }
      format.json { render tmpl }
    end
  end

  def show
    @edit = Edit.find(params[:id])
    render :layout => 'framed'
  end
end
