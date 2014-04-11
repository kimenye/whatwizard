require "test_helper"

describe Round do
  before do
    @round = Round.new
  end

  it "must be valid" do
    @round.valid?.must_equal true
  end
end
