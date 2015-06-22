# == Schema Information
#
# Table name: steps
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  step_type       :string(255)
#  order_index     :integer
#  created_at      :datetime
#  updated_at      :datetime
#  next_step_id    :integer
#  expected_answer :text(255)
#  allow_continue  :boolean
#  wrong_answer    :text
#  rebound         :text
#  action          :string(255)
#  account_id      :integer
#  wizard_id       :integer
#

class Step < ActiveRecord::Base
  has_many :progress
  has_many :questions
  has_many :contacts, through: :progress
  has_many :menus
  belongs_to :next_step, class_name: 'Step'
  belongs_to :account
  belongs_to :wizard

  # acts_as_tenant(:account)
  
  validates :order_index, uniqueness: true, presence: true
  validates :step_type, presence: true
  validates :name, presence: true

  def step_type_enum
  	[['Date of Birth','dob'], ['Opt In', 'opt-in'], ['Yes or No', 'yes-no'], ['Numeric', 'numeric'], ['Entry', 'serial'], ['Free Text', 'free-text'], ['Menu', 'menu'], ['Exact', 'exact']]
  end

  def action_enum
    [['Add to List', 'add-to-list'], ['End Conversation', 'end-conversation']]
  end
end
