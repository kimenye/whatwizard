# == Schema Information
#
# Table name: options
#
#  id         :integer          not null, primary key
#  index      :integer
#  text       :string(255)
#  key        :string(255)
#  step_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  menu_id    :integer
#

class Option < ActiveRecord::Base
	belongs_to :step
	belongs_to :menu
	belongs_to :question

	def self.get_valid_option question, text
    question.options.each do |opt|
      if opt.key.downcase == text.downcase
        return opt
      end
    end
    return nil
  end

  def self.is_valid? question, text
    return !get_valid_option(question, text).nil?
  end
end
