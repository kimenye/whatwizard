require "test_helper"

describe Action do
  before do
    @action = Action.new
  end

  it "must be valid" do
    @action.valid?.must_equal true
  end
end
