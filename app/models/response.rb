# == Schema Information
#
# Table name: responses
#
#  id            :integer          not null, primary key
#  text          :string(255)
#  progress_id   :integer
#  created_at    :datetime
#  updated_at    :datetime
#  response_type :string(255)
#

class Response < ActiveRecord::Base
  belongs_to :progress
end
