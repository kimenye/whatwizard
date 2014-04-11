class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.datetime :time

      t.timestamps
    end
  end
end
