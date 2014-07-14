# == Schema Information
#
# Table name: predictions
#
#  id         :integer          not null, primary key
#  player_id  :integer
#  match_id   :integer
#  home_score :integer
#  away_score :integer
#  confirmed  :boolean
#  created_at :datetime
#  updated_at :datetime
#

class Prediction < ActiveRecord::Base
  belongs_to :player
  belongs_to :match
end
