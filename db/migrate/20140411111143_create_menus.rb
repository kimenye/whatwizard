class CreateMenus < ActiveRecord::Migration
  def change
    create_table :menus do |t|
      t.references :step
      t.string :name

      t.timestamps
    end
  end
end
