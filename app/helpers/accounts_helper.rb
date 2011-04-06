module AccountsHelper
  def editor_for?(acct_or_obj)
    controller.editor_for?(acct_or_obj)
  end
end
