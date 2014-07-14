class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :text
      t.string :message_type
      t.integer :external_id
      t.boolean :sent
      t.boolean :received
      t.string :phone_number

      t.timestamps
    end
  end
end
