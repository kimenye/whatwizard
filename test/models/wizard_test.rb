require "test_helper"

describe Wizard do
  before do
    @wizard = Wizard.new
  end

  it "must be valid" do
    @wizard.valid?.must_equal true
  end
end
