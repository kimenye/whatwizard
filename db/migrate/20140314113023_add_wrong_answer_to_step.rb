class AddWrongAnswerToStep < ActiveRecord::Migration
  def change
    add_column :steps, :wrong_answer, :text
    change_column :steps, :expected_answer, :text
  end
end
