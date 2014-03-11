class ChangeNextStepToReferences < ActiveRecord::Migration
  def change
  	remove_column :steps, :next_step
  	add_column :steps, :next_step_id, :integer
  	add_index :steps, :next_step_id
  end
end
