require "../spec_helper"
require "../../src/models/*"
describe User do
  describe "#name" do
    puts "Test user name!"
    user = User.new("Test")
    it "correctly set name 1" do
      user.name.should eq "Test"
    end

    user2 = User.new("Def1")
    it "correctly set name 1" do
      user2.name.should eq "Def1"
    end
  end
end
