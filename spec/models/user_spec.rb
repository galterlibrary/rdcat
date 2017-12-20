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
#  admin                  :boolean          default(FALSE)
#

require 'rails_helper'

RSpec.describe User, :type => :model do
  it { should have_many(:datasets_as_author) }
  it { should have_many(:datasets_as_maintainer) }

  describe '#name' do
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

  describe 'self#find_or_create_by_username' do
    let(:ldap_entry) {
			{
        'dn' => ["uid=robo101,ou=people,dc=northwestern,dc=edu"],
        'displayname' => ["Mr Roboto"],
        'givenname' => ["Mr"],
        'sn' => ["Roboto"],
        'uid' => ["robo101"],
        'mail' => ["mr.roboto@northwestern.edu"],
        'postaladdress' => ["HD, Computer"],
        'ou' => ["Galter Health Science Library; Feinberg School of Medicine"],
        'title' => ["Developer, Senior"]
      }
		}

    subject { User.find_or_create_by_username('robo101') }

    context 'user exists' do
      let!(:user) { FactoryGirl.create(:user, username: 'robo101') }

      it 'returns the existing user' do
        expect(Ldap).not_to receive(:instance)
        expect(subject).to eq(user)
      end
    end

    context 'user does not exist' do
      it 'returns user created based on LDAP entry' do
        expect(Ldap).to receive(:instance) {
          double(Ldap, find_entry_by_netid: ldap_entry)
        }
        expect(subject).to be_an_instance_of(User)
        expect(subject.first_name).to eq('Mr')
        expect(subject.last_name).to eq('Roboto')
        expect(subject.email).to eq('mr.roboto@northwestern.edu')
        expect(subject.work_address).to eq('HD, Computer')
        expect(subject.title).to eq('Developer, Senior')
        expect(subject.affiliations).to eq([
          'Galter Health Science Library', 'Feinberg School of Medicine'
        ])
      end
    end
  end

end
