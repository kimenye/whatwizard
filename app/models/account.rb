# == Schema Information
#
# Table name: accounts
#
#  id           :integer          not null, primary key
#  phone_number :string(255)
#  auth_token   :string(255)
#  name         :string(255)
#  reset_code   :string(255)
#

class Account < ActiveRecord::Base
end
