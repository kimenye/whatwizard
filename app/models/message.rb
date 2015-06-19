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
#  account_id         :integer
#

class Message < ActiveRecord::Base

	belongs_to :account
	acts_as_tenant(:account)

	has_attached_file :image, :styles => { :medium => "480x480>", :thumb => "48x48>" }


	def deliver
		logger.info "Attempting delivery"
		if Rails.env.production? || Rails.env.development?
			sent = false
			external_id = nil

			if message_type == "Text"
	    	    url = "#{ENV['API_URL']}/send"

	    	    token = account.auth_token

	    	    logger.info "Sending ... #{{ token: token, phone_number: phone_number, text: text, thread: true }}"
	    	    response = HTTParty.post("#{url}?token=#{token}", body: {phone_number: phone_number, text: text, thread: true}, debug_output: $stdout)
	        	# response = HTTParty.post(url, body: { token: token, phone_number: phone_number, text: text, thread: true }, debug_output: $stdout)

	        	# puts "#{response}"
	        	logger.info "Received #{response.parsed_response}"

	        	sent = response.parsed_response["sent"]
	        	external_id = response.parsed_response["id"]
	        else
	        	url = "#{ENV['API_URL']}/send_image"
	        	token = account.auth_token

	        	logger.info "Sending ... #{{ token: token, phone_number: phone_number, image: image.url, thread: true }}"

	        	image_url = "#{ENV['BASE_URL']}#{image.url.split('?').first}"
	        	response = HTTParty.post(url, body: { token: token,  phone_number: phone_number, image: image_url, thread: true }, debug_output: $stdout)

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
	# handle_asynchronously :deliver
end
