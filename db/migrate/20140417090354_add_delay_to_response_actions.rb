class AddDelayToResponseActions < ActiveRecord::Migration
  def change
    add_column :response_actions, :delay, :integer
  end
end
