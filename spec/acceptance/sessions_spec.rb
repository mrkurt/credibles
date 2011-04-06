require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Sessions", %q{
  In order to manage things
  As an editor
  I want to authenticate
} do

  let :account do
    Fabricate(:account)
  end

  let :editor_token do
    account.editor_tokens.create
  end

  scenario "Login with invalid key" do
    url = "/session/new?key=asdf"
    visit url
    page.driver.status_code.should == 403
  end

  scenario "Login with a keyed URL" do
    url = "/session/new?key=#{editor_token.key}"
    visit url

    page.driver.status_code.should == 200
    editor_token.reload.use_count.should == 1
  end
end
