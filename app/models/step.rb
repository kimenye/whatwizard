# == Schema Information
#
# Table name: steps
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  step_type       :string(255)
#  order_index     :integer
#  created_at      :datetime
#  updated_at      :datetime
#  next_step_id    :integer
#  expected_answer :text(255)
#  allow_continue  :boolean
#  wrong_answer    :text
#  rebound         :text
#  action          :string(255)
#  account_id      :integer
#  wizard_id       :integer
#  final_message   :text
#

class Step < ActiveRecord::Base
  has_many :progress
  has_many :questions
  has_many :contacts, through: :progress
  has_many :menus
  has_many :options
  # belongs_to :next_step, class_name: 'Step'
  belongs_to :account
  belongs_to :wizard

  # acts_as_tenant(:account)
  
  validates :order_index, uniqueness: true, presence: true
  validates :step_type, presence: true
  validates :name, presence: true

  def get_random records
    records[rand(records.length)]
  end

  def get_question
    question = get_random(questions)    
  end

  def step_type_enum
  	[['Date of Birth','dob'], ['Opt In', 'opt-in'], ['Yes or No', 'yes-no'], ['Numeric', 'numeric'], ['Entry', 'serial'], ['Free Text', 'free-text'], ['Menu', 'menu'], ['Exact', 'exact']]
  end

  def action_enum
    [['Add to List', 'add-to-list'], ['End Conversation', 'end-conversation']]
  end

  def is_valid? response
    valid = false
    if step_type == 'menu'
      valid = !options.select{ |opt| opt.option_type != "other" && opt.key.downcase == response.downcase }.empty?
    end
    valid
  end

  def is_other? response
    !options.select{ |opt| opt.option_type == "other" && opt.key.downcase == response.downcase }.empty?
  end

  def is_last?
    next_step.nil?
  end

  def next_step
    Step.where(wizard: wizard).where('order_index > ?', order_index).order(:order_index).first
  end

  def self.is_valid_date? str
    if str.length > 8
      begin
        date = Date.parse(str)
        return self.is_over_18?(date)
      rescue ArgumentError
        return false
      end
    else
      str = str.gsub("-","/")      
      str = str.gsub(".","/")      
      begin
        date = Date.strptime(str, '%d/%m/%y')
        is_valid = self.is_over_18?(date)
        return is_valid
      rescue ArgumentError
        return false        
      end
    end    
  end

  def self.is_over_18? dt
    (Date.today - dt).to_i / 365 >= 18
  end

  def to_question
    text = questions.first.text
    if step_type == 'menu'
      text += "\r\n\r\n" + options.order(:index).collect { |opt| "#{opt.key} #{opt.text}" }.join("\r\n")
    end
    text
  end

end
