# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  username               :string           not null
#  first_name             :string
#  last_name              :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

require 'rails_helper'

RSpec.describe User, :type => :model do
  it { should have_many(:datasets_as_author) }
  it { should have_many(:datasets_as_maintainer) }

  describe '.name' do
    let(:first_name) { Faker::Name.first_name }
    let(:last_name)  { Faker::Name.last_name }

    context 'with a first and last name' do  
      let(:user) { FactoryGirl.build(:user, first_name: first_name, last_name: last_name) }
      it 'displays the full name of the user' do 
        expect(user.name).to eq(first_name + ' ' + last_name)
      end
    end

    context 'with only a first name' do  
      let(:user) { FactoryGirl.build(:user, first_name: first_name, last_name: nil) }
      it 'displays the first name of the user' do 
        expect(user.name).to eq(first_name)
      end
    end

    context 'with only a last name' do  
      let(:user) { FactoryGirl.build(:user, first_name: nil, last_name: last_name) }
      it 'displays the last name of the user' do 
        expect(user.name).to eq(last_name)
      end
    end
  end

  describe '.ldap_before_save' do 
    
  end

end
