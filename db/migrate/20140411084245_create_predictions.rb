class CreatePredictions < ActiveRecord::Migration
  def change
    create_table :predictions do |t|
      t.references :player, index: true
      t.references :match, index: true
      t.integer :home_score
      t.integer :away_score
      t.boolean :confirmed

      t.timestamps
    end
  end
end
