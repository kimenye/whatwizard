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
end
