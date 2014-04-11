class AddRoundToMatch < ActiveRecord::Migration
  def change
    add_reference :matches, :round, index: true
  end
end
