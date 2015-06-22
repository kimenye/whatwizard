# == Schema Information
#
# Table name: wizards
#
#  id            :integer          not null, primary key
#  start_keyword :string(255)
#  account_id    :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class Wizard < ActiveRecord::Base
  belongs_to :account
  acts_as_tenant(:account)
  has_many :steps
end
