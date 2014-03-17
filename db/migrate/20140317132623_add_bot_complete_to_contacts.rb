class AddBotCompleteToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :bot_complete, :boolean
  end
end
