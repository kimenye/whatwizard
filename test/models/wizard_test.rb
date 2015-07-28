# == Schema Information
#
# Table name: wizards
#
#  id            :integer          not null, primary key
#  start_keyword :string(255)
#  account_id    :integer
#  created_at    :datetime
#  updated_at    :datetime
#  name          :string(255)
#  reset_keyword :string(255)
#  restart_in    :integer
#  welcome_text  :text
#

require "test_helper"

describe Wizard do
  before do
    @wizard = Wizard.new    
  end

  it "must be valid" do
    @wizard.valid?.must_equal true
  end

  it "checks that a wizard has a unique start and reset per account" do
    account = Account.create! phone_number: '254712345678'
    account2 = Account.create! phone_number: '254787654321'

    wizard = Wizard.new(start_keyword: 'ABC', account: account)
    wizard.valid?.must_equal true
    wizard.save!

    wizard2 = Wizard.new(start_keyword: 'ABC', account: account)
    wizard2.valid?.must_equal false

    wizard2.account = account2
    wizard2.valid?.must_equal true
  end
end
