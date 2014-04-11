class ResponseAction < ActiveRecord::Base
  belongs_to :step

  def response_type_enum
  	# [['Valid','valid'], ['Invalid', 'invalid'], ['Final', 'final'], ['Rebound', 'rebound']]
  	[['Valid','valid'], ['Invalid', 'invalid'], ['Final', 'final'], ['Unknown','unknown']]  	
  end

  def action_type_enum
  	[['Add to List', 'add-to-list'], ['End Conversation', 'end-conversation'], ['Remove from List', 'remove-from-list'], ['Send Image','send-image'], ['Send Audio', 'send-audio'], ['Send Video', 'send-video'], ['Send V-Card', 'send-v-card']]
  end
end
