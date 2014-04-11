require "test_helper"

describe Team do
  before do
    @team = Team.new
  end

  it "must be valid" do
    @team.valid?.must_equal true
  end
end
