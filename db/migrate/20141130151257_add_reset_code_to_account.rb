class AddResetCodeToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :reset_code, :string
  end
end
