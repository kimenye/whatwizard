# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) can be set in the file config/application.yml.
# See http://railsapps.github.io/rails-environment-variables.html

account = Account.first
wizard = Wizard.find_or_create_by! name: "Artcaffe", start_keyword: "ARTCAFFE", account: account, reset_keyword: "Done"

# Steps

scratch = Step.find_or_create_by! name: "Scratch Card", step_type: "menu", order_index: 17,  next_step_id: nil, expected_answer: "", allow_continue: false, wrong_answer: "", rebound: "", action: nil, account: account, wizard: wizard
email = Step.find_or_create_by! name: "Email", step_type: "free-text", order_index: 16,  next_step_id: scratch.id, expected_answer: "", allow_continue: false, wrong_answer: "", rebound: "", action: nil, account: account, wizard: wizard
dob = Step.find_or_create_by! name: "DOB", step_type: "dob", order_index: 15,  next_step_id: email.id, expected_answer: "", allow_continue: false, wrong_answer: "", rebound: "", action: nil, account: account, wizard: wizard
gender = Step.find_or_create_by! name: "Gender", step_type: "menu", order_index: 14,  next_step_id: dob.id, expected_answer: "", allow_continue: false, wrong_answer: "", rebound: "", action: nil, account: account, wizard: wizard
name = Step.find_or_create_by! name: "Name", step_type: "free-text", order_index: 13,  next_step_id: gender.id, expected_answer: "", allow_continue: false, wrong_answer: "", rebound: "", action: nil, account: account, wizard: wizard
competition = Step.find_or_create_by! name: "Competition", step_type: "yes-no", order_index: 12,  next_step_id: name.id, expected_answer: "Y", allow_continue: false, wrong_answer: "X", rebound: "", action: nil, account: account, wizard: wizard
more = Step.find_or_create_by! name: "More on Waiter", step_type: "free-text", order_index: 10,  next_step_id: competition.id, expected_answer: "", allow_continue: false, wrong_answer: "", rebound: "", action: nil, account: account, wizard: wizard
waiter = Step.find_or_create_by! name: "Waiter", step_type: "free-text", order_index: 11,  next_step_id: more.id, expected_answer: "", allow_continue: false, wrong_answer: "", rebound: "", action: nil, account: account, wizard: wizard
service_quality = Step.find_or_create_by! name: "Quality of Service", step_type: "menu", order_index: 8,  next_step_id: waiter.id, expected_answer: "", allow_continue: false, wrong_answer: "", rebound: "", action: nil, account: account, wizard: wizard
food_quality = Step.find_or_create_by! name: "Quality of Food", step_type: "menu", order_index: 9,  next_step_id: service_quality.id, expected_answer: "", allow_continue: false, wrong_answer: "", rebound: "", action: nil, account: account, wizard: wizard
frequency = Step.find_or_create_by! name: "Frequency", step_type: "menu", order_index: 6,  next_step_id: food_quality.id, expected_answer: "", allow_continue: false, wrong_answer: "", rebound: "", action: nil, account: account, wizard: wizard
branch = Step.find_or_create_by! name: "Branch", step_type: "menu", order_index: 7,  next_step_id: frequency.id, expected_answer: "", allow_continue: false, wrong_answer: "", rebound: "", action: nil, account: account, wizard: wizard

# Questions

branch_q = Question.find_or_create_by! text: "Thank you for visiting Artcaffe. Your feedback is essential to helping them improve their offering. Please let us know which branch you are reviewing today:", step: branch, language: "en", account: account
frequency_q = Question.find_or_create_by! text: "How often do you dine at Artcaffe?", step: frequency, language: "en", account: account
food_q = Question.find_or_create_by! text: "How was your last meal there?", step: food_quality, language: "en", account: account
service_q = Question.find_or_create_by! text: "How was the service from your server?", step: service_quality, language: "en", account: account
waiter_q = Question.find_or_create_by! text: "Please let us know your waiter's name. Please press 'X' if you don't remember.", step: waiter, language: "en", account: account
more_q = Question.find_or_create_by! text: "Please share anything else you would like to add. To skip this step type 'X'", step: more, language: "en", account: account
competition_q = Question.find_or_create_by! text: 'Thank you for taking the time to share your feedback. Would you like to participate in our monthly competition? You stand a chance of winning a fantastic trip to Mombasa, coffee & meal vouchers and much more. Type "Y" to participate, "X" to exit.', step: competition, language: "en", account: account
name_q = Question.find_or_create_by! text: "Please type your Full name below:", step: name, language: "en", account: account
gender_q = Question.find_or_create_by! text: "What is your gender?", step: gender, language: "en", account: account
dob_q = Question.find_or_create_by! text: "Please enter your date of birth", step: dob, language: "en", account: account
email_q = Question.find_or_create_by! text: "Please type a valid email address:", step: email, language: "en", account: account
scratch_q = Question.find_or_create_by! text: "Scratch card:", step: scratch, language: "en", account: account

# Options

Option.find_or_create_by! text: "OVAL", key: "1", step_id: branch.id, question_id: branch_q.id
Option.find_or_create_by! text: "YAYA", key: "2", step_id: branch.id, question_id: branch_q.id
Option.find_or_create_by! text: "JUNCTION", key: "3", step_id: branch.id, question_id: branch_q.id
Option.find_or_create_by! text: "LAVINGTON", key: "4", step_id: branch.id, question_id: branch_q.id
Option.find_or_create_by! text: "GIGIRI", key: "5", step_id: branch.id, question_id: branch_q.id
Option.find_or_create_by! text: "GALLERIA", key: "6", step_id: branch.id, question_id: branch_q.id
Option.find_or_create_by! text: "TRM", key: "7", step_id: branch.id, question_id: branch_q.id
Option.find_or_create_by! text: "Daily", key: "1", step_id: frequency.id, question_id: frequency_q.id
Option.find_or_create_by! text: "Weekly", key: "2", step_id: frequency.id, question_id: frequency_q.id
Option.find_or_create_by! text: "Monthly", key: "3", step_id: frequency.id, question_id: frequency_q.id
Option.find_or_create_by! text: "Once in three months or less", key: "4", step_id: frequency.id, question_id: frequency_q.id
Option.find_or_create_by! text: "I loved the food, Yummy!", key: "1", step_id: food_quality.id, question_id: food_q.id
Option.find_or_create_by! text: "I thought the food was good", key: "2", step_id: food_quality.id, question_id: food_q.id
Option.find_or_create_by! text: "The food was ok but could be better.", key: "3", step_id: food_quality.id, question_id: food_q.id
Option.find_or_create_by! text: "The food was disappointing, please do something about it.", key: "4", step_id: food_quality.id, question_id: food_q.id
Option.find_or_create_by! text: "Our server was awesome. Good job!", key: "1", step_id: service_quality.id, question_id: service_q.id
Option.find_or_create_by! text: "Our server was pretty good, but not perfect.", key: "2", step_id: service_quality.id, question_id: service_q.id
Option.find_or_create_by! text: "Our server was average. Definitely room for improvement.", key: "3", step_id: service_quality.id, question_id: service_q.id
Option.find_or_create_by! text: "Our server was horrible, please do something about it.", key: "4", step_id: service_quality.id, question_id: service_q.id
Option.find_or_create_by! text: "Male", key: "1", step_id: gender.id, question_id: gender_q.id
Option.find_or_create_by! text: "Female", key: "2", step_id: gender.id, question_id: gender_q.id
Option.find_or_create_by! text: "Better luck next time", key: "1", question_id: scratch_q.id
Option.find_or_create_by! text: "You have won a coffee on the house", key: "2", question_id: scratch_q.id
Option.find_or_create_by! text: "You have won a meal voucher", key: "3", question_id: scratch_q.id
Option.find_or_create_by! text: "You have won a flight to Mombasa", key: "4", question_id: scratch_q.id

# SystemResponses

SystemResponse.find_or_create_by! text: "Thank you again for sharing your thoughts with us.", response_type: "valid", step_id: scratch.id, language: "en", account: account
SystemResponse.find_or_create_by! text: "Good. We will pass it on to him.", response_type: "valid", step_id: waiter.id, language: "en", account: account
SystemResponse.find_or_create_by! text: "Thanks", response_type: "valid", step_id: more.id, language: "en", account: account
SystemResponse.find_or_create_by! text: "Did anyone tell you that you have a beautiful name?", response_type: "valid", step_id: name.id, language: "en", account: account
SystemResponse.find_or_create_by! text: "You are sure this is your email address?", response_type: "valid", step_id: 16, language: "en", account: account
SystemResponse.find_or_create_by! text: "OK. Bye! :(", response_type: "invalid", step_id: competition.id, language: "en", account: account
SystemResponse.find_or_create_by! text: "Good. Now, about that competition.", response_type: "valid", step_id: competition.id, language: "en", account: account
SystemResponse.find_or_create_by! text: "You are too young", response_type: "invalid", step_id: dob.id, language: "en", account: account
SystemResponse.find_or_create_by! text: "Looks good to me", response_type: "valid", step_id: dob.id, language: "en", account: account
SystemResponse.find_or_create_by! text: "That option does not exit. Try again.", response_type: "invalid", step_id: food_quality.id, language: "en", account: account
SystemResponse.find_or_create_by! text: "That option does not exit. Please try again.", response_type: "invalid", step_id: service_quality.id, language: "en", account: account
SystemResponse.find_or_create_by! text: "That option does not exit. Please try again.", response_type: "invalid", step_id: gender.id, language: "en", account: account
SystemResponse.find_or_create_by! text: "That option does not exit. Please try again.", response_type: "invalid", step_id: frequency.id, language: "en", account: account
SystemResponse.find_or_create_by! text: "That option does not exit. Please try again.", response_type: "invalid", step_id: branch.id, language: "en", account: account
SystemResponse.find_or_create_by! text: "I don't know what you are talking about", response_type: "invalid", step_id: scratch.id, language: "en", account: account

# ResponseActions

ResponseAction.find_or_create_by! name: "Not interested", parameters: "X", action_type: "end-conversation", response_type: "final", step_id: competition.id
ResponseAction.find_or_create_by! name: "Interested", parameters: "Y", action_type: "add-to-list", response_type: "valid", step_id: competition.id

