class ChangeNextStepToReferences < ActiveRecord::Migration
  def change
  	# change_column :steps, :next_step_id, :string
  	remove_column :steps, :next_step
  	add_column :steps, :next_step_id, :integer
  	add_index :steps, :next_step_id
  end
end
