class CreateSteps < ActiveRecord::Migration
  def change
    create_table :steps do |t|
      t.string :name
      t.string :step_type
      t.string :next_step
      t.integer :order_index

      t.timestamps
    end
  end
end
