class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.integer :phone_number
      t.string :name
      t.boolean :opted_in

      t.timestamps
    end
  end
end
