# == Schema Information
#
# Table name: options
#
#  id         :integer          not null, primary key
#  index      :integer
#  text       :string(255)
#  key        :string(255)
#  step_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  menu_id    :integer
#

class Option < ActiveRecord::Base
	belongs_to :step
	belongs_to :menu
	belongs_to :question
end
