# == Schema Information
#
# Table name: wizards
#
#  id            :integer          not null, primary key
#  start_keyword :string(255)
#  account_id    :integer
#  created_at    :datetime
#  updated_at    :datetime
#  name          :string(255)
#

require "test_helper"

describe Wizard do
  before do
    @wizard = Wizard.new
  end

  it "must be valid" do
    @wizard.valid?.must_equal true
  end
end
