require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  before do
  	Contact.delete_all
  	Step.delete_all
  	Question.delete_all
  	Progress.delete_all
    SystemResponse.delete_all
    Response.delete_all
    Language.delete_all

    Language.create! code: "swa", name: "Swahili"
    Language.create! code: "en", name: "English"
    ENV['DEFAULT_LANGUAGE'] = "swa"
  end

  test "Should return the restart method when the contact sends the reset code" do
    post :wizard_new, { notification_type: "MessageReceived", name: "dsfsdf", phone_number: "254722778348", text: "#{ENV['RESET_CODE']}"}
    assert_response :success

    expected = { response: [{ type: "Response", text: "Send #{ENV['RESTART_CODE']} to restart", phone_number: "254722778348" }] }
    assert_equal expected.to_json, response.body
  end

  test "Should use the default language if the contact has not specified one yet" do
    opt_step = Step.create! name: "Age Gate", step_type: "dob", order_index: 0
    eng_qn = Question.create! text: "Hello {{contact_name}}.", step_id: opt_step.id, language: "en"
    swa_qn = Question.create! text: "Habari {{contact_name}}", step_id: opt_step.id, language: "swa"
    swa_valid = SystemResponse.create! text: "Karibu {{contact_name}}", step_id: opt_step.id, language: "swa", response_type: "valid"
    en_valid = SystemResponse.create! text: "Welcome {{contact_name}}", step_id: opt_step.id, language: "en", response_type: "valid"
    
    post :wizard_new, { notification_type: "MessageReceived", name: "dsfsdf", phone_number: "254722778348", text: "01/11/1986"}
    assert_response :success 

    expected = { response: [{ type: "Question", text: "Habari dsfsdf", phone_number: "254722778348" }] }
    assert_equal expected.to_json, response.body

    contact = Contact.find_by_phone_number("254722778348")  

    post :wizard_new, { notification_type: "MessageReceived", name: "dsfsdf", phone_number: "254722778348", text: "01/11/1986"}
    assert_response :success 

    expected = { response: [ swa_valid.to_result(contact) ] }
    assert_equal expected.to_json, response.body
  end

  test "Should use the correct format for age validation" do
    opt_step = Step.create! name: "Age Gate", step_type: "dob", order_index: 0
    SystemResponse.create! text: "Cool!", step_id: opt_step.id, response_type: "valid", language: "swa"
    SystemResponse.create! text: "Wrong!", step_id: opt_step.id, response_type: "invalid", language: "swa"

    contact = Contact.create! name: "dsfsdf", phone_number: "254722778348", opted_in: nil
    progress = Progress.create! step_id: opt_step.id, contact_id: contact.id

    post :wizard_new, { notification_type: "MessageReceived", name: "dsfsdf", phone_number: "254722778348", text: "01/11/1986"}
    assert_response :success

    expected = { response: [{ type: "Response", text: "Cool!", phone_number: "254722778348" }] }
    assert_equal expected.to_json, response.body  

    contact = Contact.find_by_phone_number("254722778348")  
    assert_equal true, contact.opted_in
  end

  test "Should validate correct date formats" do
    assert_equal true, HomeController.is_valid_date?("01/11/1986")
    assert_equal false, HomeController.is_valid_date?("23/23/1986")
    assert_equal true, HomeController.is_valid_date?("11/01/86")
    assert_equal true, HomeController.is_valid_date?("11/1/86")
    assert_equal true, HomeController.is_valid_date?("11-1-86")
    assert_equal true, HomeController.is_valid_date?("11-01-86")
    assert_equal false, HomeController.is_valid_date?("01/11/2006")
  end


  test "Should be over 18 even if using the correct date format" do
    opt_step = Step.create! name: "Age Gate", step_type: "dob", order_index: 0
    SystemResponse.create! text: "Cool!", step_id: opt_step.id, response_type: "valid"
    SystemResponse.create! text: "Wrong!", step_id: opt_step.id, response_type: "invalid"

    contact = Contact.create! name: "dsfsdf", phone_number: "254722778348", language: "en", opted_in: nil
    progress = Progress.create! step_id: opt_step.id, contact_id: contact.id

    post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "01/11/2006"}
    assert_response :success

    expected = { response: [{ type: "Response", text: "Wrong!", phone_number: "254722778348" }] }
    assert_equal expected.to_json, response.body  

    contact = Contact.find_by_phone_number("254722778348")  
    assert_equal false, contact.opted_in
  end

  test "Should mark the wrong date format for age validation" do
    opt_step = Step.create! name: "Age Gate", step_type: "dob", order_index: 0
    SystemResponse.create! text: "Cool!", step_id: opt_step.id, response_type: "valid"
    SystemResponse.create! text: "Wrong!", step_id: opt_step.id, response_type: "invalid"

    contact = Contact.create! name: "dsfsdf", phone_number: "254722778348", opted_in: nil, language: "en"
    progress = Progress.create! step_id: opt_step.id, contact_id: contact.id

    post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "23/23/1986"}
    assert_response :success

    expected = { response: [{ type: "Response", text: "Wrong!", phone_number: "254722778348" }] }
    assert_equal expected.to_json, response.body  
  end

  test "should create a contact if it doesn't already exist" do  	
    post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "yes"}
    assert_response :success
    contact = Contact.find_by_phone_number("254722778348") 
    assert_equal false, contact.nil?    
  end

  test "An action can have a delayed execution" do
    opt_step = Step.create! name: "Opt-In", step_type: "yes-no", order_index: 0, expected_answer: "Yes", wrong_answer: "No"
    action = ResponseAction.create! name: "Opt in list", step_id: opt_step.id, action_type: "add-to-list", response_type: "valid", parameters: "opt-in-list", delay: 20
    SystemResponse.create! text: "Cool!", step_id: opt_step.id, response_type: "valid"

    contact = Contact.create! name: "dsfsdf", phone_number: "254722778348", opted_in: true, language: "en"
    progress = Progress.create! step_id: opt_step.id, contact_id: contact.id

    post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "Yes"}
    assert_response :success 

    expected = { response: [{ type: "Response", text: "Cool!", phone_number: "254722778348" }, { type: "Action", name: "Opt in list", action_type: "add-to-list", parameters: "opt-in-list", delay: 20 }] }
    assert_equal expected.to_json, response.body
  end

  test "A test can have one or more actions" do
    opt_step = Step.create! name: "Opt-In", step_type: "yes-no", order_index: 0, expected_answer: "Yes", wrong_answer: "No"
    action = ResponseAction.create! name: "Opt in list", step_id: opt_step.id, action_type: "add-to-list", response_type: "valid", parameters: "opt-in-list"
    SystemResponse.create! text: "Cool!", step_id: opt_step.id, response_type: "valid"
    
    contact = Contact.create! name: "dsfsdf", phone_number: "254722778348", opted_in: true, language: "en"
    progress = Progress.create! step_id: opt_step.id, contact_id: contact.id

    post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "Yes"}
    assert_response :success 

    expected = { response: [{ type: "Response", text: "Cool!", phone_number: "254722778348" }, { type: "Action", name: "Opt in list", action_type: "add-to-list", parameters: "opt-in-list" }] }
    assert_equal expected.to_json, response.body  
  end

  test "A test can have more than one action especially if it is a rebound" do
    next_step = Step.create! name: "Final", step_type: "free-text", order_index: 1
    prompt = Question.create! text: "Why should you win this?", step_id: next_step.id
    step = Step.create! name: "Customer", step_type: "yes-no", order_index: 0, expected_answer: "yes", wrong_answer: "no", rebound: "Heineken", next_step_id: next_step.id
    action = ResponseAction.create! name: "Not a customer", step_id: step.id, action_type: "add-to-list", parameters: "Non-Customers", response_type: "invalid"
    removeAction = ResponseAction.create! name: "Rebound customer", step_id: step.id, action_type: "remove-from-list", parameters: "Non-Customers", response_type: "valid"
    invalid = SystemResponse.create! text: "Too bad", step_id: step.id, response_type: "invalid"
    valid = SystemResponse.create! text: "Cool", step_id: step.id, response_type: "valid"
    rebound = SystemResponse.create! text: "Good to hear from you again. Did you enjoy a world-class Heineken since last time?", step_id: step.id, response_type: "rebound"

    contact = Contact.create! name: "dsfsdf", phone_number: "254722778348", opted_in: true, language: "en"
    progress = Progress.create! step_id: step.id, contact_id: contact.id

    post :wizard, { name: "dssd", phone_number: "254722778348", text: "no" }
    assert_response :success

    expected = { response: [{ type: "Response", text: "Too bad", phone_number: "254722778348" }, { type: "Action", name: "Not a customer", action_type: "add-to-list", parameters: "Non-Customers" }] }
    assert_equal expected.to_json, response.body    

    post :wizard, { name: "dssd", phone_number: "254722778348", text: "Heineken"}
    assert_response :success

    expected = { response: [{ type: "Response", text: rebound.text, phone_number: "254722778348" }]}
    assert_equal expected.to_json, response.body  

    post :wizard, { name: "dssd", phone_number: "254722778348", text: "yes"}
    assert_response :success

    expected = { response: [{ type: "Response", text: valid.text, phone_number: "254722778348" }, { type: 'Question', text: prompt.text, phone_number: "254722778348" }, { type: "Action", name: removeAction.name, action_type: removeAction.action_type, parameters: removeAction.parameters }] }
    assert_equal expected.to_json, response.body    
  end

  test "A step can have more than one action" do
    step = Step.create! name: "Customer", step_type: "yes-no", order_index: 0, expected_answer: "yes", wrong_answer: "no", rebound: "Heineken"
    action = ResponseAction.create! name: "Not a customer", step_id: step.id, action_type: "add-to-list", parameters: "Non-Customers", response_type: "invalid"
    endConversation = ResponseAction.create! name: "Rebound customer", step_id: step.id, action_type: "end-conversation", response_type: "invalid"
    invalid = SystemResponse.create! text: "Too bad", step_id: step.id, response_type: "invalid"

    contact = Contact.create! name: "dsfsdf", phone_number: "254722778348", opted_in: true, language: "en"
    progress = Progress.create! step_id: step.id, contact_id: contact.id

    post :wizard, { name: "dssd", phone_number: "254722778348", text: "no" }
    assert_response :success

    expected = { response: [{ type: "Response", text: invalid.text, phone_number: "254722778348" }, 
        { type: "Action", name: action.name, action_type: action.action_type, parameters: action.parameters },
        { type: "Action", name: endConversation.name, action_type: endConversation.action_type, parameters: endConversation.parameters }] }

    assert_equal expected.to_json, response.body
  end

  test "When a user finishes the bot interaction they are marked as complete" do
    final_step = Step.create! name: "Final", step_type: "free-text", order_index: 0
    SystemResponse.create! text: "Thank you for your time", step_id: final_step.id, response_type: "final"
    SystemResponse.create! text: "Awesome", step_id: final_step.id, response_type: "valid"

    contact = Contact.create! name: "dsfsdf", phone_number: "254722778348", opted_in: true, language: "en"
    progress = Progress.create! step_id: final_step.id, contact_id: contact.id

    post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "Heineken is awesome"}
    assert_response :success

    expected = { response: [{ type: "Response", text: "Awesome", phone_number: "254722778348" }, { type: "Response", text: "Thank you for your time", phone_number: "254722778348" }] }
    assert_equal expected.to_json, response.body    

    contact = Contact.find_by_phone_number("254722778348") 
    assert_equal true, contact.bot_complete 

    post :wizard, { name: "dsfsdf", phone_number: "254722778348", text: "So, what happens next?" }
    assert_response :success

    expected = { response: [] }
    assert_equal expected.to_json, response.body 

    post :wizard, { name: "dsfsdf", phone_number: "254722778348", text: ENV["RESET_CODE"] }
    assert_response :success

    contact = Contact.find_by_phone_number("254722778348") 
    assert_equal true, contact.nil?    
  end

  test "When a user sends a message after they are marked as complete they get the autoresponder message" do
    final_step = Step.create! name: "Final", step_type: "opt-in", order_index: 0, expected_answer: "yes", wrong_answer: "no"
    SystemResponse.create! text: "Awesome", step_id: final_step.id, response_type: "valid"
    SystemResponse.create! text: "Please just chill", step_id: final_step.id, response_type: "end"

    contact = Contact.create! name: "dsfsdf", phone_number: "254722778348", opted_in: nil, language: "en"
    progress = Progress.create! step_id: final_step.id, contact_id: contact.id

    post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "yes"}
    assert_response :success

    expected = { response: [{ type: "Response", text: "Awesome", phone_number: "254722778348" }] }
    assert_equal expected.to_json, response.body    

    contact = Contact.find_by_phone_number("254722778348") 
    assert_equal true, contact.bot_complete 

    post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "What is?"}
    assert_response :success

    expected = { response: [{ type: "Response", text: "Please just chill", phone_number: "254722778348" }] }
    assert_equal expected.to_json, response.body
  end

  test "Reset deletes the message and asks the user to text in Heineken" do
    next_step = Step.create! name: "Heineken Consumer", step_type: "yes-no", order_index: 1
    opt_in_step = Step.create! name: "Opt-In", step_type: "opt-in", order_index: 0, expected_answer: "Yes, yeah", wrong_answer: "No, no!, I'm not", next_step_id: next_step.id
    qn = Question.create! text: "Niaje {{contact_name}}! Before we continue, are you over 18. Please reply with Yes or No.", step_id: opt_in_step.id, language: "swa"
    rsp = SystemResponse.create! text: "Sorry only 18 and over", response_type: "invalid", step_id: opt_in_step.id, language: "swa"
    SystemResponse.create! text: "Karibu", response_type: "valid", step_id: opt_in_step.id, language: "swa"
    post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "Heineken is awesome"}
    assert_response :success

    expected = { response: [{ type: "Question", text: "Niaje dsfsdf! Before we continue, are you over 18. Please reply with Yes or No.", phone_number: "254722778348" }] }
    assert_equal expected.to_json, response.body

    post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "Yes"}
    assert_response :success

    contact = Contact.find_by_phone_number("254722778348") 
    assert_equal false, contact.nil?    
    assert_equal true, contact.opted_in

    post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: ENV["RESET_CODE"]}
    assert_response :success

    contact = Contact.find_by_phone_number("254722778348") 
    assert_equal true, contact.nil?

    expected = { response: [{ type: "Response", text: "Type #{ENV['RESTART_CODE']} to restart", phone_number: "254722778348" }] }
    assert_equal expected.to_json, response.body    

    post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "Heineken"}
    assert_response :success

    contact = Contact.find_by_phone_number("254722778348") 
    assert_equal false, contact.nil?
    assert_equal nil, contact.opted_in

    post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "No"}
    assert_response :success  

    contact = Contact.find_by_phone_number("254722778348") 
    assert_equal false, contact.opted_in

    expected = { response: [{ type: "Response", text: "Sorry only 18 and over", phone_number: "254722778348" }] }
    assert_equal expected.to_json, response.body   
  end

  test "It should send a question from the first step if a contact has not engaged with the system before" do
  	opt_in_step = Step.create! name: "Opt-In", step_type: "opt-in", order_index: 0
  	qn = Question.create! text: "Niaje {{contact_name}}! Before we continue, are you over 18. Please reply with Yes or No.", step_id: opt_in_step.id, language: "swa"
  	post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "Heineken is awesome"}
  	assert_response :success

  	contact = Contact.find_by_phone_number("254722778348")

  	progress = Progress.where("contact_id =? and step_id = ?", contact.id, opt_in_step.id).order(id: :desc).last
  	assert_equal opt_in_step.id, progress.step.id
  	

  	expected = { response: [{ type: "Question", text: "Niaje dsfsdf! Before we continue, are you over 18. Please reply with Yes or No.", phone_number: "254722778348" }] }
  	assert_equal expected.to_json, response.body
  end

  test "It should opt a contact in if the contact answers yes to an opt-in question" do
 	  opt_in_step = Step.create! name: "Opt-In", step_type: "opt-in", order_index: 0, expected_answer: "Yes, Yea, Ndio"
    action = ResponseAction.create! name: "Add-to-List", step_id: opt_in_step.id, action_type: "add-to-list", response_type: "valid", parameters: "opt-in-list"
  	qn = Question.create! text: "Niaje {{contact_name}}! Before we continue, are you over 18. Please reply with Yes or No.", step_id: opt_in_step.id, language: "swa"

	  post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "Heineken is awesome"}
  	assert_response :success

  	post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "Yes"}  	
  	assert_response :success

    expected = { response: [{ type: "Action", name: "Add-to-List", action_type: "add-to-list", parameters: "opt-in-list" }] }
    assert_equal expected.to_json, response.body

  	contact = Contact.find_by_phone_number("254722778348") 
  	assert_equal true, contact.opted_in
  end

  test "It should opt-out a contact if the contact answers no to an opt-in question" do
 	  opt_in_step = Step.create! name: "Opt-In", step_type: "opt-in", order_index: 0, expected_answer: "Yes, Yea, Ndio"
  	qn = Question.create! text: "Niaje {{contact_name}}! Before we continue, are you over 18. Please reply with Yes or No.", step_id: opt_in_step.id, language: "swa"
  	rsp = SystemResponse.create! text: "Grow up first", step_id: opt_in_step.id, response_type: "invalid", language: "swa"

	  post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "Heineken is awesome"}
  	assert_response :success

  	post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "No"}  	
  	assert_response :success

  	contact = Contact.find_by_phone_number("254722778348") 
  	assert_equal false, contact.opted_in

  	expected = { response: [{ type: "Response", text: rsp.text, phone_number: "254722778348" }] }
  	assert_equal expected.to_json, response.body

  	# what happens if a contact opt-out.
  	post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "Yes"}  	
  	assert_response :success

  	# we will not opt them in again.
  	# we will send them the same response
  	contact = Contact.find_by_phone_number("254722778348") 
  	assert_equal false, contact.opted_in
  end

  test "It should advance the progress to the next step if the user opts-in" do
  	next_step = Step.create! name: "Heineken Consumer", step_type: "yes-no", order_index: 1
 	  opt_in_step = Step.create! name: "Opt-In", step_type: "opt-in", order_index: 0, next_step_id: next_step.id, expected_answer: "Yes, Yea, Ndio", wrong_answer: "no"
  	qn = Question.create! text: "Niaje {{contact_name}}! Before we continue, are you over 18. Please reply with Yes or No.", step_id: opt_in_step.id, language: "swa"
  	next_qn = Question.create! text: "Cool. Are you a Heineken Consumer. Please reply with Yes or No?", step_id: next_step.id, language: "swa"

	  post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "Heineken is awesome"}
  	assert_response :success

  	post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "Yes"}  	
  	assert_response :success

  	contact = Contact.find_by_phone_number("254722778348") 
  	current = Progress.where("contact_id =?", contact.id).order(id: :asc).last

  	assert_equal next_step.id, current.step_id 

  	# need to test that the response to the api is the next question
  	expected = { response: [{ type: "Question", text: "Cool. Are you a Heineken Consumer. Please reply with Yes or No?", phone_number: "254722778348" }] }
  	assert_equal expected.to_json, response.body
  end 

  test "It should send a different response for a different question based on the response" do
  	next_step = Step.create! name: "Number of drinks per week", step_type: "numeric", order_index: 1, expected_answer: "20"
   	above = SystemResponse.create! text: "Slow down tiger", step_id: next_step.id, response_type: "more_than"
   	equal = SystemResponse.create! text: "Thats amazing", step_id: next_step.id, response_type: "equals"
   	below = SystemResponse.create! text: "Drink some more", step_id: next_step.id, response_type: "less_than"
  	

  	contact = Contact.create! name: "dsfsdf", phone_number: "254722778348", opted_in: true
  	progress = Progress.create! step_id: next_step.id, contact_id: contact.id

  	post :wizard, { name: "dssd", phone_number: "254722778348", text: "10" }
  	assert_response :success

  	expected = { response: [{ type: "Response", text: below.text, phone_number: "254722778348" }] }
  	assert_equal expected.to_json, response.body
  end

  test "It should accept a yes or no if any of the response is included" do
    step = Step.create! name: "Yes No", step_type: "yes-no", order_index: 1, expected_answer: "yes, definitely, off course, yeah, yea, yup,ofcourse, of course, ndio, yep, affirmative", wrong_answer: "no, never, nah, nope, nop, not"

    assert_equal true, HomeController.matches_search?(step.expected_answer, "yes I do")
    assert_equal true, HomeController.matches_search?(step.expected_answer, "definitely")
    assert_equal true, HomeController.matches_search?(step.expected_answer, "yes definitely")
    assert_equal true, HomeController.matches_search?(step.expected_answer, "Hell yeah")
    assert_equal true, HomeController.matches_search?(step.expected_answer, "yes please take me")
    assert_equal false, HomeController.matches_search?(step.expected_answer, "no")
  end

  test "It should accept a valid serial number based on the response" do
  	next_step = Step.create! name: "Collect Serial", step_type: "serial", order_index: 1, expected_answer: '[(3|4)][(0|1|2|3)]\d{5}[a-zA-Z][(0|1|2|3)]\d{3}'

  	valid = SystemResponse.create! text: "That's awesome. Super cool", step_id: next_step.id, response_type: "valid"
 	  equal = SystemResponse.create! text: "Sorry that's not a valid serial", step_id: next_step.id, response_type: "invalid"
 	
 	  contact = Contact.create! name: "dsfsdf", phone_number: "254722778348", opted_in: true, language: "en"
  	progress = Progress.create! step_id: next_step.id, contact_id: contact.id


 	  post :wizard, { name: "dssd", phone_number: "254722778348", text: "3212345d3123" }
  	assert_response :success

	  expected = { response: [{ type: "Response", text: valid.text, phone_number: "254722778348" }] }
  	assert_equal expected.to_json, response.body  	
  end

  test "It should NOT accept the test serial number" do
    next_step = Step.create! name: "Collect Serial", step_type: "serial", order_index: 1, expected_answer: '\d{13}', wrong_answer: "8712000900205"    
    fake = SystemResponse.create! text: "LOL! That's my production code. Please enter yours when you next enjoy a Heineken", step_id: next_step.id, response_type: "fake", language: "swa"
  
    contact = Contact.create! name: "dsfsdf", phone_number: "254722778348", opted_in: true
    progress = Progress.create! step_id: next_step.id, contact_id: contact.id


    post :wizard, { name: "dssd", phone_number: "254722778348", text: "8712000900205" }
    assert_response :success

    expected = { response: [{ type: "Response", text: fake.text, phone_number: "254722778348" }] }
    assert_equal expected.to_json, response.body    
  end

  test "It should progress a person to the next step question if it is a yes no question and they answer with yes" do
  	next_step = Step.create! name: "Collect Serial", step_type: "serial", order_index: 1, expected_answer: "/d{13}/"
  	question = Question.create! text: "In order to stand a chance to win a trip to Ibiza, send us the 13 digit code on the side of your bottle. The more you enter the better your chances of winning.", step_id: next_step.id
  	step = Step.create! name: "Customer", step_type: "yes-no", order_index: 0, expected_answer: "yes, yeah, offcourse, sometimes", next_step_id: next_step.id
  	valid = SystemResponse.create! text: "That's awesome. Super cool", step_id: step.id, response_type: "valid"


  	contact = Contact.create! name: "dsfsdf", phone_number: "254722778348", opted_in: true, language: "en"
  	progress = Progress.create! step_id: step.id, contact_id: contact.id

  	post :wizard, { name: "dssd", phone_number: "254722778348", text: "yes" }
  	assert_response :success

  	expected = { response: [{ type: "Response", text: valid.text, phone_number: "254722778348" }, { type: "Question", text: question.text, phone_number: contact.phone_number }]}
  	assert_equal expected.to_json, response.body  	  	
  end

  test "It should progress a person to the next step question if it is a yes no question and they answer with no but the step is marked as can allow to continue" do
    next_step = Step.create! name: "Collect Serial", step_type: "serial", order_index: 1, expected_answer: "/d{13}/"
    question = Question.create! text: "In order to stand a chance to win a trip to Ibiza, send us the 13 digit code on the side of your bottle. The more you enter the better your chances of winning.", step_id: next_step.id
    step = Step.create! name: "Customer", step_type: "yes-no", order_index: 0, expected_answer: "yes, yeah, offcourse, sometimes", wrong_answer: "no", next_step_id: next_step.id, allow_continue: true
    valid = SystemResponse.create! text: "That's awesome. Super cool", step_id: step.id, response_type: "invalid"


    contact = Contact.create! name: "dsfsdf", phone_number: "254722778348", opted_in: true, language: "en"
    progress = Progress.create! step_id: step.id, contact_id: contact.id

    post :wizard, { name: "dssd", phone_number: "254722778348", text: "no" }
    assert_response :success

    expected = { response: [{ type: "Response", text: valid.text, phone_number: "254722778348" }, { type: "Question", text: question.text, phone_number: contact.phone_number}]}
    assert_equal expected.to_json, response.body        
  end

  test "It should NOT progress a person to the next step question if it is a yes no question and they answer with no" do
  	next_step = Step.create! name: "Collect Serial", step_type: "serial", order_index: 1, expected_answer: "/d{13}/"
  	question = Question.create! text: "In order to stand a chance to win a trip to Ibiza, send us the 13 digit code on the side of your bottle. The more you enter the better your chances of winning.", step_id: next_step.id
  	step = Step.create! name: "Customer", step_type: "yes-no", order_index: 0, expected_answer: "yes, yeah, offcourse, sometimes", next_step_id: next_step.id, wrong_answer: "no"  	
  	invalid = SystemResponse.create! text: "Sorry, only got time for serious chaps", step_id: step.id, response_type: "invalid"


  	contact = Contact.create! name: "dsfsdf", phone_number: "254722778348", opted_in: true, language: "en"
  	progress = Progress.create! step_id: step.id, contact_id: contact.id

  	post :wizard, { name: "dssd", phone_number: "254722778348", text: "no" }
  	assert_response :success

  	expected = { response: [{ type: "Response", text: invalid.text, phone_number: "254722778348" }]}
  	assert_equal expected.to_json, response.body  	  	
  end

  test "It should accept any text for free form answer" do
    step = Step.create! name: "Man of the World", step_type: "free-text", order_index: 0, expected_answer: ""
    question = Question.create! text: "Why are you a man of the world?", step_id: step.id

    valid = SystemResponse.create! text: "Mmh. Humility is not one of your strengths.", step_id: step.id, response_type: "valid"

    contact = Contact.create! name: "dsfsdf", phone_number: "254722778348", opted_in: true, language: "en"
    progress = Progress.create! step_id: step.id, contact_id: contact.id

    post :wizard, { name: "dssd", phone_number: "254722778348", text: "and i cannot lie" }
    assert_response :success

    expected = { response: [{ type: "Response", text: valid.text, phone_number: "254722778348" }] }
    assert_equal expected.to_json, response.body        
  end

  test "If a user provides an answer that is not part of what is expected then we should prompt them that we didn't undestand" do
    next_step = Step.create! name: "Entry", step_type: "free-text", order_index: 1 
    step = Step.create! name: "Campaign", step_type: "yes-no", order_index: 0, expected_answer: "yes", wrong_answer: "no"
    first_question = Question.create! text: "So {{customer_name}}, are you ready to go to Lisbon to watch the UEFA Champions League final?"
    unknown = SystemResponse.create! text: "Did't quite get that...", step_id: step.id, response_type: "unknown"

    contact = Contact.create! name: "dsfsdf", phone_number: "254722778348", opted_in: true, language: "en"
    progress = Progress.create! step_id: step.id, contact_id: contact.id

    post :wizard, { name: "dssd", phone_number: "254722778348", text: "go to hell!" }
    assert_response :success

    expected = { response: [{ type: "Response", text: unknown.text, phone_number: "254722778348" }]}
    assert_equal expected.to_json, response.body
  end

  test "If a user gives a wrong answer then later gives the rebound phrase, they can get asked the same question" do
    step = Step.create! name: "Customer", step_type: "yes-no", order_index: 0, expected_answer: "yes", wrong_answer: "no", rebound: "Heineken"
    invalid = SystemResponse.create! text: "Then there's some good news: you can get one in a bar near you! :) reply with 'Heineken' once you've tasted that quality", step_id: step.id, response_type: "invalid"
    rebound = SystemResponse.create! text: "Good to hear from you again. Did you enjoy a world-class Heineken since last time?", step_id: step.id, response_type: "rebound"

    contact = Contact.create! name: "dsfsdf", phone_number: "254722778348", opted_in: true, language: "en"
    progress = Progress.create! step_id: step.id, contact_id: contact.id

    post :wizard, { name: "dssd", phone_number: "254722778348", text: "no" }
    assert_response :success

    post :wizard, { name: "dssd", phone_number: "254722778348", text: "Heineken"}
    assert_response :success

    expected = { response: [{ type: "Response", text: rebound.text, phone_number: "254722778348" }]}
    assert_equal expected.to_json, response.body
  end

  it "Should accept an image or video if the step allows for it" do
    final = Step.create! name: "Challenge", step_type: "free-text", order_index: 1
    step = Step.create! name: "Customer", step_type: "serial", order_index: 0, expected_answer: "yes", wrong_answer: "8712000900205", next_step_id: final.id
    prompt = Question.create! text: "Why should you win this?", step_id: final.id, language: "swa"

    valid_video = SystemResponse.create! text: "Well, let me take a look at that", response_type: "multimedia", step_id: step.id, language: "swa"
    contact = Contact.create! name: "dsfsdf", phone_number: "254722778348", opted_in: true
    progress = Progress.create! step_id: step.id, contact_id: contact.id

    post :wizard, { name: "dssd", phone_number: "254722778348", multimedia: true }
    assert_response :success

    expected = { response: [{ type: "Response", text: valid_video.text, phone_number: "254722778348"}, { type: "Question", text: prompt.text, phone_number: "254722778348"}]}
    assert_equal expected.to_json, response.body    
  end

  it "Should save all user input correct or wrong" do
    first = Step.create! name: "Level 1", step_type: "exact", order_index: 0, expected_answer: "sesame!", allow_continue: false
    # prompt = Question.create! text: "Open What?", step_id: first.id, language: "swa"

    contact = Contact.create! phone_number: "255722200200", name: "Blah"
    progress = Progress.create! step: first, contact: contact
    wrong = SystemResponse.create! text: "Go away, you're not ali baba", response_type: "invalid", step: first, language: "swa"

    post :wizard, { name: "Ali baba", phone_number: "255722200200", text: "sesame seeds" }
    assert_response :success

    m = Response.find_by(progress: progress, text: "sesame seeds", response_type: "Text")
    assert_not m.nil?
  end

  it "Should reject a wrong answer to an exact step" do
    first = Step.create! name: "Level 1", step_type: "exact", order_index: 0, expected_answer: "sesame!", allow_continue: false
    # prompt = Question.create! text: "Open What?", step_id: first.id, language: "swa"

    contact = Contact.create! phone_number: "255722200200", name: "Blah"
    progress = Progress.create! step: first, contact: contact
    wrong = SystemResponse.create! text: "Go away, you're not ali baba", response_type: "invalid", step: first, language: "swa"

    post :wizard, { name: "Ali baba", phone_number: "255722200200", text: "sesame seeds" }
    assert_response :success
  end
end
