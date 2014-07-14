# == Schema Information
#
# Table name: media
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  remote_asset_id    :integer
#

class Media < ActiveRecord::Base
	# belongs_to :question
	# belongs_to :system_response
	has_attached_file :image, :styles => { :medium => "480x480>", :thumb => "48x48>" }

	def uploaded
		!remote_asset_id.nil?
  	end
end
