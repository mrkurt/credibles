require "spec_helper"

describe UserMailer do
  let :edit do
    Fabricate(:edit)
  end

  it "should send change emails" do
    EditWorker.change(edit.id, ['new', 'good'], 'kurt rules')
    mail = ActionMailer::Base.deliveries.pop
    mail.should_not be_nil
    mail.subject.should include("Re: Proposed edit on #{edit.url}")
    mail.body.should include('+best+')
  end
end
