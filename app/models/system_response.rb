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
  	{ type: "Response", text: personalize(contact), phone_number: contact.phone_number }
  end
end
