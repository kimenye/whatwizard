class Match < ActiveRecord::Base
	belongs_to :round
	# has_many :teams

	belongs_to :home_team, class_name: "Team"
	belongs_to :away_team, class_name: "Team"
end
