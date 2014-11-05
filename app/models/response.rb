# == Schema Information
#
# Table name: responses
#
#  id          :integer          not null, primary key
#  text        :string(255)
#  progress_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class Response < ActiveRecord::Base
  belongs_to :progress
end
