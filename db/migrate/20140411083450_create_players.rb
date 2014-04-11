class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :phone_number
      t.string :name
      t.references :team, index: true
      t.boolean :subscribed

      t.timestamps
    end
  end
end
