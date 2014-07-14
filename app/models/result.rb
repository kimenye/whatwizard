# == Schema Information
#
# Table name: results
#
#  id         :integer          not null, primary key
#  match_id   :integer
#  home_score :integer
#  away_score :integer
#  created_at :datetime
#  updated_at :datetime
#

class Result < ActiveRecord::Base
  belongs_to :match
end
