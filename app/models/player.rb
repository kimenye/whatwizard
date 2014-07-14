# == Schema Information
#
# Table name: players
#
#  id           :integer          not null, primary key
#  phone_number :string(255)
#  name         :string(255)
#  team_id      :integer
#  subscribed   :boolean
#  created_at   :datetime
#  updated_at   :datetime
#

class Player < ActiveRecord::Base
  belongs_to :team
end
