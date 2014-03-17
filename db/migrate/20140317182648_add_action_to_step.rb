class AddActionToStep < ActiveRecord::Migration
  def change
    add_column :steps, :action, :string
  end
end
