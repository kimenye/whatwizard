require "test_helper"

describe Match do
  before do
    @match = Match.new
  end

  it "must be valid" do
    @match.valid?.must_equal true
  end
end
