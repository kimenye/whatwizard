# == Schema Information
#
# Table name: progresses
#
#  id         :integer          not null, primary key
#  contact_id :integer
#  step_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  player_id  :integer
#  response   :text
#

class Progress < ActiveRecord::Base
  belongs_to :contact
  belongs_to :step
end
