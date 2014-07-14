# == Schema Information
#
# Table name: rounds
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  name       :string(255)
#

class Round < ActiveRecord::Base
	has_many :matches
end
