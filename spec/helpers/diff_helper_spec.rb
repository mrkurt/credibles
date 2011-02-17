require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the DiffHelper. For example:
#
# describe DiffHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe DiffHelper do
  let :suggestion do
    Edit::Suggestion.new(:original => 'this is a test', :proposed => 'this is the best')
  end
  describe "#diff_before" do
    let :diff do
      helper.diff_before(suggestion)
    end
    it "should only show deletes" do
      diff.should_not include('best')
      diff.should_not include('<ins')
    end

    it "should collapse adjacent deletes" do
      diff.should_not include('</del> <del')
    end
  end

  describe "#diff_after" do
    let :diff do
      helper.diff_after(suggestion)
    end
    it "should only show inserts" do
      diff.should_not include('test')
      diff.should_not include('<del')
    end

    it "should collapse adjacent inserts" do
      diff.should_not include('</ins> <ins')
    end
  end
end
