class AddExpectedAnswerToStep < ActiveRecord::Migration
  def change
    add_column :steps, :expected_answer, :string
  end
end
