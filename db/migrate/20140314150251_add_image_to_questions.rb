class AddImageToQuestions < ActiveRecord::Migration
  def change
  	add_attachment :questions, :image
    add_column :questions, :remote_asset_id, :integer
  end
end
