require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  before do
  	Contact.delete_all
  	Step.delete_all
  	Question.delete_all
  	Progress.delete_all
  end

  test "should create a contact if it doesn't already exist" do
  	
    post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "yes"}
    assert_response :success
    contact = Contact.find_by_phone_number("254722778348") 
    assert_equal false, contact.nil?    
  end

  test "It should send a question from the first step if a contact has not engaged with the system before" do
  	opt_in_step = Step.create! name: "Opt-In", step_type: "opt-in", order_index: 0
  	qn = Question.create! text: "Niaje {{contact_name}}! Before we continue, are you over 18. Please reply with Yes or No.", step_id: opt_in_step.id
  	post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "Heineken is awesome"}
  	assert_response :success

  	contact = Contact.find_by_phone_number("254722778348")

  	progress = Progress.where("contact_id =? and step_id = ?", contact.id, opt_in_step.id).order(id: :desc).last
  	assert_equal opt_in_step.id, progress.step.id
  	

  	expected = { response: { type: "Question", text: "Niaje dsfsdf! Before we continue, are you over 18. Please reply with Yes or No.", phone_number: "254722778348" }}
  	assert_equal expected.to_json, response.body
  end

  test "It should opt a contact in if the contact answers yes to an opt-in question" do
 	opt_in_step = Step.create! name: "Opt-In", step_type: "opt-in", order_index: 0
  	qn = Question.create! text: "Niaje {{contact_name}}! Before we continue, are you over 18. Please reply with Yes or No.", step_id: opt_in_step.id

	post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "Heineken is awesome"}
  	assert_response :success

  	post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "yes"}  	
  	assert_response :success

  	contact = Contact.find_by_phone_number("254722778348") 
  	assert_equal true, contact.opted_in
  end

   test "It should opt-out a contact if the contact answers no to an opt-in question" do
 	opt_in_step = Step.create! name: "Opt-In", step_type: "opt-in", order_index: 0
  	qn = Question.create! text: "Niaje {{contact_name}}! Before we continue, are you over 18. Please reply with Yes or No.", step_id: opt_in_step.id

	post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "Heineken is awesome"}
  	assert_response :success

  	post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "No"}  	
  	assert_response :success

  	contact = Contact.find_by_phone_number("254722778348") 
  	assert_equal false, contact.opted_in
  end

  test "It should advance the progress to the next step if the user opts-in" do
  	next_step = Step.create! name: "Heineken Consumer", step_type: "yes-no", order_index: 1
 	opt_in_step = Step.create! name: "Opt-In", step_type: "opt-in", order_index: 0, next_step_id: next_step.id
  	qn = Question.create! text: "Niaje {{contact_name}}! Before we continue, are you over 18. Please reply with Yes or No.", step_id: opt_in_step.id
  	next_qn = Question.create! text: "Cool. Are you a Heineken Consumer. Please reply with Yes or No?", step_id: next_step.id

	post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "Heineken is awesome"}
  	assert_response :success

  	post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "Yes"}  	
  	assert_response :success

  	contact = Contact.find_by_phone_number("254722778348") 
  	current = Progress.where("contact_id =?", contact.id).order(id: :asc).last

  	assert_equal next_step.id, current.step_id 

  	# need to test that the response to the api is the next question
  	expected = { response: { type: "Question", text: "Cool. Are you a Heineken Consumer. Please reply with Yes or No?", phone_number: "254722778348" }}
  	assert_equal expected.to_json, response.body
  end 
end
