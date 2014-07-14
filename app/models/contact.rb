# == Schema Information
#
# Table name: contacts
#
#  id           :integer          not null, primary key
#  phone_number :string(255)
#  name         :string(255)
#  opted_in     :boolean
#  created_at   :datetime
#  updated_at   :datetime
#  bot_complete :boolean
#  language     :string(255)
#

class Contact < ActiveRecord::Base
  has_many :progress
  has_many :steps, through: :progress
end
