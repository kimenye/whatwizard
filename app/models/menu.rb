# == Schema Information
#
# Table name: menus
#
#  id         :integer          not null, primary key
#  step_id    :integer
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  action     :string(255)
#

class Menu < ActiveRecord::Base
	belongs_to :step
	has_many :options

	def action_enum
		[['Subscribe', 'subscribe'], ['Pick Team','pick-team']]
	end
end
