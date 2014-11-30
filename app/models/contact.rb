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
#  account_id   :integer
#

class Contact < ActiveRecord::Base
  has_many :progress, dependent: :delete_all
  has_many :steps, through: :progress

  belongs_to :account
  acts_as_tenant(:account)
end
