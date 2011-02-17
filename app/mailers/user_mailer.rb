class UserMailer < ActionMailer::Base
  default :from => "copypasta@credibl.es"
  helper :edits
  helper :diff

  def edit_change_notice(edit, status, msg)
    @edit = edit
    @status_changes = status
    @editor_notes = msg
    from = "copypasta <copypasta+edit-#{edit.id}@credibl.es>"
    mail(:to => edit.email, :from => from, :subject => "Re: Proposed edit on #{edit.page.url}", :bcc => 'kurt@mubble.net')
  end
end
