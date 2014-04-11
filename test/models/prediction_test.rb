require "test_helper"

describe Prediction do
  before do
    @prediction = Prediction.new
  end

  it "must be valid" do
    @prediction.valid?.must_equal true
  end
end
