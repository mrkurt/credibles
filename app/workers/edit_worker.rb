class EditWorker < ApplicationWorker
  @queue = :normal
  class << self
    def create(id)
      e = Edit.find(id)
      return unless e.account.editors.is_a?(Array)
      e.account.editors.each do |e1|
        EditorMailer.new_edit_notice(e, e1).deliver
      end
    end

    def change(id, status, msg)
      e = Edit.find(id)

      UserMailer.edit_change_notice(e, status, msg).deliver if status || msg
    end
  end
end
