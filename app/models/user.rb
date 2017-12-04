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

class User < ActiveRecord::Base

  has_many :datasets_as_author,     class_name: 'Dataset', foreign_key: 'author_id'
  has_many :datasets_as_maintainer, class_name: 'Dataset', foreign_key: 'maintainer_id'

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :ldap_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  after_save do
    self.datasets_as_author.each {|ds| ds.__elasticsearch__.index_document }
    self.datasets_as_maintainer.each {|ds| ds.__elasticsearch__.index_document }
  end

  around_destroy do
    #TODO
  end

  def ldap_before_save
    return if Rails.env.development? && ENV['BYPASS_LDAP'] == 'true'
    self.email      = Devise::LDAP::Adapter.get_ldap_param(self.username,'mail').first
    self.first_name = Devise::LDAP::Adapter.get_ldap_param(self.username,'givenName').first
    self.last_name  = Devise::LDAP::Adapter.get_ldap_param(self.username,'sn').first
  end

  def name
    "#{first_name} #{last_name}".strip
  end

  require 'ldap'
  def self.find_or_create_by_username(username)
    user = User.where(username: username).first
    if user.nil?
      if ldap_entry = Ldap.instance.find_entry_by_netid(username)
        user = User.new(username: username)
        user.email = ldap_entry['mail'].first
        user.first_name = ldap_entry['givenName'].first
        user.last_name = ldap_entry['sn'].first
        user.password = Devise.friendly_token[0, 20]
        user.save!
      end
    end
    user
  end
end
