class AddQuestionToOption < ActiveRecord::Migration
  def change
    add_reference :options, :question, index: true
  end
end
