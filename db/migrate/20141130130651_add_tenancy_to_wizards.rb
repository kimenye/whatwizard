class AddTenancyToWizards < ActiveRecord::Migration
  def change
  	create_table :accounts do |t|
  		t.string :phone_number
  		t.string :auth_token
  		t.string :name
  	end

  	add_reference :contacts, :account, index: true
  	add_reference :messages, :account, index: true
  	add_reference :questions, :account, index: true
  	add_reference :responses, :account, index: true
  	add_reference :steps, :account, index: true
  	add_reference :system_responses, :account, index: true
  end
end
