class Step < ActiveRecord::Base
  has_many :progress
  has_many :questions
  has_many :contacts, through: :progress
  has_many :menus
  belongs_to :next_step, class_name: 'Step'

  validates :order_index, uniqueness: true, presence: true
  validates :step_type, presence: true
  validates :name, presence: true

  def step_type_enum
  	[['Opt In', 'opt-in'], ['Yes or No', 'yes-no'], ['Numeric', 'numeric'], ['Entry', 'serial'], ['Free Text', 'free-text'], ['Menu', 'menu']]
  end

  def action_enum
    [['Add to List', 'add-to-list'], ['End Conversation', 'end-conversation']]
  end
end
