# == Schema Information
#
# Table name: matches
#
#  id           :integer          not null, primary key
#  time         :datetime
#  created_at   :datetime
#  updated_at   :datetime
#  home_team_id :integer
#  away_team_id :integer
#  round_id     :integer
#

class Match < ActiveRecord::Base
	belongs_to :round
	# has_many :teams

	belongs_to :home_team, class_name: "Team"
	belongs_to :away_team, class_name: "Team"
end
