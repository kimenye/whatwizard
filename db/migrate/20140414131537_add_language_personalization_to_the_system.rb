class AddLanguagePersonalizationToTheSystem < ActiveRecord::Migration
  def change
  	add_column :questions, :language, :string, default: "en"
  	add_column :system_responses, :language, :string, default: "en"
  	add_column :contacts, :language, :string
  end
end
