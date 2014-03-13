class CreateAddImageToResponses < ActiveRecord::Migration
  def change
    add_attachment :system_responses, :image
    add_column :system_responses, :remote_asset_id, :integer
  end
end
