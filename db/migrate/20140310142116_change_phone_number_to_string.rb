class ChangePhoneNumberToString < ActiveRecord::Migration
  def change
  	change_column :contacts, :phone_number, :string
  end
end
