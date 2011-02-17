require 'spec_helper'

describe Edit do
  it "should sanitize html" do
    e = Edit.new(:comments => '<script>alert("hello");</script>')
    e.valid?

    e.comments.should_not include('<script>')
  end

  context "#events" do
    let :edit do
      Fabricate(:edit)
    end

    it "should add a notification job on create" do
      e = edit
      args = Resque.peek('normal', -1)['args']
      args.first.should == 'create'
      args[1].should == e.id.to_s
    end

    it "should add a notification job on change" do
      edit.update_attributes(:status => 'good')
      args = Resque.peek('normal', -1)['args']
      args.first.should == 'change'
      args[1].should == edit.id.to_s
    end
  end
end
