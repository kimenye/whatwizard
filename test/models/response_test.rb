# == Schema Information
#
# Table name: responses
#
#  id            :integer          not null, primary key
#  text          :string(255)
#  progress_id   :integer
#  created_at    :datetime
#  updated_at    :datetime
#  response_type :string(255)
#

require "test_helper"

describe Response do
  before do
    @response = Response.new
  end

  it "must be valid" do
    @response.valid?.must_equal true
  end
end
