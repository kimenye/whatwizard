class AddResetKeywordToWizard < ActiveRecord::Migration
  def change
    add_column :wizards, :reset_keyword, :string
  end
end
