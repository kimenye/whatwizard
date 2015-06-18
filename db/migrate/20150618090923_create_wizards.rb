class CreateWizards < ActiveRecord::Migration
  def change
    create_table :wizards do |t|
      t.string :start_keyword
      t.references :account, index: true

      t.timestamps
    end
  end
end
