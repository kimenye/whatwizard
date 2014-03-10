require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "should create a contact if it doesn't already exist" do
  	Contact.delete_all
    post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "yes"}
    assert_response :success
    contact = Contact.find_by_phone_number("254722778348") 
    assert_equal false, contact.nil?
  end

  test "It should send a question from the first step if a contact has not engaged with the system before" do
  	Contact.delete_all
  	opt_in_step = Step.create! name: "Opt-In", step_type: "opt-in", order_index: 0
  	qn = Question.create! text: "Niaje {{contact_name}}! Before we continue, are you over 18. Please reply with Yes or No.", step_id: opt_in_step.id
  	post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "Heineken is awesome"}
  	assert_response :success

  	contact = Contact.find_by_phone_number("254722778348")

  	progress = Progress.where("contact_id =? and step_id = ?", contact.id, opt_in_step.id).order(id: :desc).last
  	assert_equal opt_in_step.id, progress.step.id
  end

end
