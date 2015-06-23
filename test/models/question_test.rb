require "test_helper"

describe Question do
  test "Should return the right string message for a question" do
    step = Step.create! name: 'DOB', order_index: 0, step_type: 'dob'
    question = Question.create! step: step, text: 'How old are you {{contact_name}}?'
    contact = Contact.new phone_number: '254705866564', name: 'Trevor'

    message = question.to_message contact
  end
end