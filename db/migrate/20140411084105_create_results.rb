class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.references :match, index: true
      t.integer :home_score
      t.integer :away_score

      t.timestamps
    end
  end
end
