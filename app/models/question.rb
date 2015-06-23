# == Schema Information
#
# Table name: questions
#
#  id                 :integer          not null, primary key
#  text               :text
#  step_id            :integer
#  created_at         :datetime
#  updated_at         :datetime
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  remote_asset_id    :integer
#  media_id           :integer
#  language           :string(255)      default("en")
#  account_id         :integer
#

class Question < ActiveRecord::Base
  belongs_to :step
  belongs_to :media
  has_many :options
  has_attached_file :image, :styles => { :medium => "480x480>", :thumb => "48x48>" }

  belongs_to :account
  # acts_as_tenant(:account)

  def uploaded
  	!remote_asset_id.nil?
  end

  def language_enum
  	[['English', 'en'], ['Swahili', 'swa']]
  end

  def personalize contact
  	text.gsub(/{{contact_name}}/, contact.name.blank? ? "" : contact.name)
  end

  def to_result contact
  	{ type: "Question", text: personalize(contact), phone_number: contact.phone_number }
  end

  def options_text
    options.collect { |opt| "#{opt.key}. #{opt.text}" }.join("\r\n")    
  end

  def to_message contact
    personalize(contact)
  end
end
