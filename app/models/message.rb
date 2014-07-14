# == Schema Information
#
# Table name: messages
#
#  id                 :integer          not null, primary key
#  text               :string(255)
#  message_type       :string(255)
#  external_id        :integer
#  sent               :boolean
#  received           :boolean
#  phone_number       :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#

class Message < ActiveRecord::Base

	has_attached_file :image, :styles => { :medium => "480x480>", :thumb => "48x48>" }


	def deliver
		if Rails.env.production?
			sent = false
			external_id = nil

			if message_type == "Text"
	    	    url = "#{ENV['API_URL']}/send"

	    	    logger.info "Sending ... #{{ token: ENV['API_TOKEN'], phone_number: phone_number, text: text, thread: true }}"
	        	response = HTTParty.post(url, body: { token: ENV['API_TOKEN'], phone_number: phone_number, text: text, thread: true }, debug_output: $stdout)

	        	# puts "#{response}"
	        	logger.info "Received #{response.parsed_response}"

	        	sent = response.parsed_response["sent"]
	        	external_id = response.parsed_response["id"]
	        else
	        	url = "#{ENV['API_URL']}/send_image"
	        	logger.info "Sending ... #{{ token: ENV['API_TOKEN'], phone_number: phone_number, image: image.url, thread: true }}"

	        	image_url = "#{ENV['BASE_URL']}#{image.url.split('?').first}"
	        	response = HTTParty.post(url, body: { token: ENV['API_TOKEN'],  phone_number: phone_number, image: image_url, thread: true }, debug_output: $stdout)

	        	logger.info "Received #{response.parsed_response}"
	        	sent = response.parsed_response["sent"]
	        	external_id = response.parsed_response["id"]
	        end
        	
        	m = Message.find(id)
        	m.sent = sent
        	m.external_id = external_id
        	m.save!
      	end
	end
	handle_asynchronously :deliver
end
