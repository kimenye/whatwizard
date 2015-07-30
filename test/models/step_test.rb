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
#

require "test_helper"

describe Step do
  test "Should validate correct date formats" do
    assert_equal true, Step.is_valid_date?("01/11/1986")
    assert_equal false, Step.is_valid_date?("23/23/1986")
    assert_equal true, Step.is_valid_date?("11/01/86")
    assert_equal true, Step.is_valid_date?("11/1/86")
    assert_equal true, Step.is_valid_date?("11-1-86")
    assert_equal true, Step.is_valid_date?("11-01-86")
    assert_equal false, Step.is_valid_date?("01/11/2006")
  end

  test "Should get the correct question for a menu type" do
    step = steps(:italian)
    question = questions(:italian)

    options = step.options.order(:index).collect { |opt| "#{opt.key} #{opt.text}" }.join("\r\n")

    assert_equal 'menu', step.step_type
    expected = "#{question.text}\r\n\r\n#{options}"

    assert_equal expected, step.to_question
  end

  test "Should be able to evaluate if an option is valid" do
    step = steps(:italian)

    assert step.is_valid? '1'
    assert step.is_valid? '2'
    assert_not step.is_valid? 'blah'
    
    # other option
    assert_not step.is_valid? '3'
  end

  test "Should be able to get the next step in a wizard" do

    step = steps(:italian)
    assert_not step.is_last?

    continental = steps(:continental)
    assert_equal continental, step.next_step
  end

  test "Should be able to tell if the option is other" do
    step = steps(:italian)
    assert step.is_other? '3'
    assert_not step.is_other? '1'
  end

end
