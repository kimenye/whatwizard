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
#  reset_keyword :string(255)
#

class Wizard < ActiveRecord::Base
  belongs_to :account
  acts_as_tenant(:account)
  has_many :steps

  validates_uniqueness_of :start_keyword, scope: :account_id
  validates_uniqueness_of :reset_keyword, scope: :account_id


  def start contact
    first_step = steps.order(order_index: :asc).first
    progress = Progress.create! step: first_step, contact: contact

    question = first_step.get_question

    { progress: progress.id, message: question.to_message(contact) }
  end

  def reset contact
    phone_number = contact.phone_number
    Progress.where(contact_id: contact.id).destroy_all
    contact.delete
    
    text = "Send #{ActsAsTenant.current_tenant.start_code} to begin"
    msg = Message.create! text: text, contact: contact
    msg.deliver
    [{ type: "Response", text: text, phone_number: phone_number }]
  end

  def self.get_starting_wizards start
    Wizard.where('start_keyword like ? ', start)
  end

  def self.get_reset_wizards reset_keyword
    Wizard.where('reset_keyword like ? ', reset_keyword)
  end
end
