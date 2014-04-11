class AddTeamsToMatch < ActiveRecord::Migration
  def change
  	add_column :matches, :home_team_id, :integer
  	add_index :matches, :home_team_id
  	add_column :matches, :away_team_id, :integer
  	add_index :matches, :away_team_id
  end
end
