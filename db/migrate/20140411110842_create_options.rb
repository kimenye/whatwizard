class CreateOptions < ActiveRecord::Migration
  def change
    create_table :options do |t|
      t.integer :index
      t.string :text
      t.string :key
      t.references :step

      t.timestamps
    end
  end
end
