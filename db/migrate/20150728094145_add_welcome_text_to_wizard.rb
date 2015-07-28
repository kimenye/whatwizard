class AddWelcomeTextToWizard < ActiveRecord::Migration
  def change
    add_column :wizards, :welcome_text, :text
  end
end
