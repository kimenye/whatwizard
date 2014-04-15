class Question < ActiveRecord::Base
  belongs_to :step
  belongs_to :media
  has_attached_file :image, :styles => { :medium => "480x480>", :thumb => "48x48>" }

  def uploaded
  	!remote_asset_id.nil?
  end

  def language_enum
  	[['English', 'en'], ['Swahili', 'swa']]
  end

  def personalize contact
  	text.gsub(/{{contact_name}}/, contact.name)
  end

  def to_result contact
  	{ type: "Question", text: personalize(contact), phone_number: contact.phone_number }
  end
end
