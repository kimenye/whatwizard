class CreateProgresses < ActiveRecord::Migration
  def change
    create_table :progresses do |t|
      t.references :contact, index: true
      t.references :step, index: true

      t.timestamps
    end
  end
end
