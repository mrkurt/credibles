require "spec_helper"

describe EditorMailer do
  let :edit do
    Fabricate(:edit)
  end

  it "should send creation emails" do
    EditWorker.create(edit.id)
    mail = ActionMailer::Base.deliveries.pop
    mail.should_not be_nil
    mail.subject.should include("Corrections for #{edit.url}")
    mail.body.should include('+best+')
  end
end
