class SystemResponse < ActiveRecord::Base

  belongs_to :media  
  belongs_to :step
  has_attached_file :image, :styles => { :medium => "480x480>", :thumb => "48x48>" }

  def response_type_enum
    [ ['Valid','valid'], ['Invalid', 'invalid'], ['More Than', 'more_than'], ['Less Than', 'less_than'], ['Equal', 'equal'], ['Unknown','unknown'], ['Rebound', 'rebound'], ['Multimedia', 'multimedia'], ['Fake', 'fake'], ['Final', 'final'], ['End', 'end']]
  end

  # def uploaded
  # 	!remote_asset_id.nil?
  # end
end
