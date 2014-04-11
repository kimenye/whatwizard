class Option < ActiveRecord::Base
	belongs_to :step
	belongs_to :menu
end
