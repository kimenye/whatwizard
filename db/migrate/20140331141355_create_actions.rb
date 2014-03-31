class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.string :name
      t.string :parameters
      t.string :action_type
      t.string :response_type
      t.references :step, index: true

      t.timestamps
    end
  end
end
