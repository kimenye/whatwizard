class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.text :text
      t.references :step, index: true

      t.timestamps
    end
  end
end
