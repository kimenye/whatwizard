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
#

class Progress < ActiveRecord::Base
  belongs_to :contact
  belongs_to :step
  has_many :response, dependent: :destroy
end
