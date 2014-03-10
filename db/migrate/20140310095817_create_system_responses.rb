class CreateSystemResponses < ActiveRecord::Migration
  def change
    create_table :system_responses do |t|
      t.string :text
      t.string :response_type
      t.references :step, index: true

      t.timestamps
    end
  end
end
