# == Schema Information
#
# Table name: messages
#
#  id                 :integer          not null, primary key
#  text               :string(255)
#  message_type       :string(255)
#  external_id        :integer
#  sent               :boolean
#  received           :boolean
#  phone_number       :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#

require "test_helper"

describe Message do
  before do
    @message = Message.new
  end

  it "must be valid" do
    @message.valid?.must_equal true
  end
end
