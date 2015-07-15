# == Schema Information
#
# Table name: questions
#
#  id                 :integer          not null, primary key
#  text               :text
#  step_id            :integer
#  created_at         :datetime
#  updated_at         :datetime
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  remote_asset_id    :integer
#  media_id           :integer
#  language           :string(255)      default("en")
#  account_id         :integer
#

require "test_helper"

describe Question do
  test "Should return the right string message for a question" do
    step = Step.create! name: 'DOB', order_index: 0, step_type: 'dob'
    question = Question.create! step: step, text: 'How old are you {{contact_name}}?'
    contact = Contact.new phone_number: '254705866564', name: 'Trevor'

    message = question.to_message contact
  end
end
