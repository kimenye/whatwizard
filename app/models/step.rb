class Step < ActiveRecord::Base
  has_many :progress
  has_many :questions
  has_many :contacts, through: :progress
  belongs_to :next_step, class_name: 'Step'

  validates :order_index, uniqueness: true
end
