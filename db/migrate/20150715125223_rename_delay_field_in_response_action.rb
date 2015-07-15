class RenameDelayFieldInResponseAction < ActiveRecord::Migration
  def change
	rename_column :response_actions, :delay, :delay_by
  end
end
