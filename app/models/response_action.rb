class ResponseAction < ActiveRecord::Base
  belongs_to :step

  def response_type_enum
  	[['Valid','valid'], ['Invalid', 'invalid'], ['Final', 'final']]
  end

  def action_type_enum
  	[['Add to List', 'add-to-list'], ['End Conversation', 'end-conversation'], ['Remove from List', 'remove-from-list']]
  end
end
