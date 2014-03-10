class Contact < ActiveRecord::Base
  has_many :progress
  has_many :steps, through: :progress
end
