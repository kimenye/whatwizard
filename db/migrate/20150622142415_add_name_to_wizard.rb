class AddNameToWizard < ActiveRecord::Migration
  def change
    add_column :wizards, :name, :string
  end
end
