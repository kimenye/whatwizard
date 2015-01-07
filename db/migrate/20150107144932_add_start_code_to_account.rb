class AddStartCodeToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :start_code, :string
  end
end
