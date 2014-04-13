class Menu < ActiveRecord::Base
	belongs_to :step
	has_many :options

	def action_enum
		[['Subscribe', 'subscribe'], ['Pick Team','pick-team']]
	end
end
