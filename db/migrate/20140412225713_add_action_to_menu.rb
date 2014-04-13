class AddActionToMenu < ActiveRecord::Migration
  def change
    add_column :menus, :action, :string
  end
end
