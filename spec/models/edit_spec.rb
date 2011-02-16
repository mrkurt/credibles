require 'spec_helper'

describe Edit do
  it "should sanitize html" do
    e = Edit.new(:comments => '<script>alert("hello");</script>')
    e.valid?

    e.comments.should_not include('<script>')
  end

  it "should add a notification job on create" do
    
  end

  it "should add a notification job on change" do
  end
end
