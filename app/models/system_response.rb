# == Schema Information
#
# Table name: system_responses
#
#  id                 :integer          not null, primary key
#  text               :text(255)
#  response_type      :string(255)
#  step_id            :integer
#  created_at         :datetime
#  updated_at         :datetime
#  value              :string(255)
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  remote_asset_id    :integer
#  media_id           :integer
#  language           :string(255)      default("en")
#

class SystemResponse < ActiveRecord::Base

  belongs_to :media  
  belongs_to :step
  has_attached_file :image, :styles => { :medium => "480x480>", :thumb => "48x48>" }

  def response_type_enum
    [['Valid','valid'], ['Invalid', 'invalid'], ['More Than', 'more_than'], ['Less Than', 'less_than'], ['Equal', 'equal'], ['Unknown','unknown'], ['Rebound', 'rebound'], ['Multimedia', 'multimedia'], ['Fake', 'fake'], ['Final', 'final'], ['End', 'end'], ['Completed', 'completed']]
  end

  def language_enum
    [['English', 'en'], ['Swahili', 'swa']]
  end

  def personalize contact
  	text.gsub(/{{contact_name}}/, contact.name)
  end

  def to_result contact
    if image.url == "/images/original/missing.png"
      { type: "Response", text: personalize(contact), phone_number: contact.phone_number }
    else
      { type: "ImageResponse", text: personalize(contact), phone_number: contact.phone_number, image: image }
    end
  end
end
