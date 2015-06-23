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
end
