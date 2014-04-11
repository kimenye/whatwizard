require "test_helper"

describe Result do
  before do
    @result = Result.new
  end

  it "must be valid" do
    @result.valid?.must_equal true
  end
end
