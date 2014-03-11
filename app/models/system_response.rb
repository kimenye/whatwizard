class SystemResponse < ActiveRecord::Base
  belongs_to :step

  def response_type_enum
  	[ ['Valid','valid'], ['Invalid', 'invalid'], ['More Than', 'more_than'], ['Less Than', 'less_than'], ['Equal', 'equal']]
  end
end
