class ChangeSystemResponseType < ActiveRecord::Migration
  def change
  	change_column :system_responses, :text, :text
  end
end
