class EditorMailer < ActionMailer::Base
  default :from => "copypasta <copypasta@credibl.es>"
  helper :edits, :diff

  def new_edit_notice(edit, editor_email)
    @edit = edit
    @token = edit.account.editor_tokens.create(:for => editor_email)

    mail(:to => editor_email, :from => edit.email, :subject => "Corrections for #{edit.page.url}", :bcc => 'kurt@mubble.net')
  end

  def edit_message(edit, editor, options = {})
    @options = options
    @edit = edit
    name = options[:from_name]
    name = 'copypasta' if name.blank?

    from = "#{name} <copypasta+edit-#{edit.id}-#{edit.key}@credibl.es>"

    mail(:to => editor.email, :from => from, :subject => "Re: Corrections for #{edit.page.url}", :bcc => 'kurt@mubble.net')
  end
end
