# -*- coding: utf-8 -*-
require 'net/ldap'

##
# Helper class to retrieve attributes about members
# through the Northwestern LDAP directory
class Ldap

  # Singleton pattern
  @@instance = Ldap.new

  def self.instance
    @@instance
  end

  # The known attributes available to us through LDAP
  ATTRIBUTES = [
    'title',
    'displayname',
    'givenname',
    'cn',
    'sn',
    'mail',
    'ou',
    'uid',
    'uidnumber',
    'dn',
    'facsimiletelephonenumber',
    'telephonenumber',
    'postaladdress'
  ]

  ##
  # Helper method to retrieve an entry via netid
  # @see find_entry
  # @param [String]
  # @return [Net::LDAP::Entry]
  def find_entry_by_netid(netid)
    find_entry(netid, 'uid')
  end

  ##
  # Helper method to retrieve an entry via email address
  # @see find_entry
  # @param [String]
  # @return [Net::LDAP::Entry]
  def find_entry_by_email(email)
    find_entry(email, 'mail')
  end

  ##
  # Method to retrieve an LDAP entry from a key
  # @see find_entry
  # @param [String]
  # @return [Net::LDAP::Entry]
  def find_entry(value, key = 'uid')
    find_ldap_entry(Net::LDAP::Filter.eq(key, value))
  end

  ##
  # Create the Net::LDAP object
  # @return [Net:LDAP]
  def get_connection
    Net::LDAP.new({ host: server, port: port })
  end
  private :get_connection

  def find_ldap_entry(user_filter)
    entry   = nil
    entries = nil
    begin
      Timeout::timeout(3) { entries = get_connection.search(base: treebase, filter: user_filter) }
      entry   = clean_ldap_entry(entries[0]) unless entries.blank?
    rescue Timeout::Error
      Rails.logger.error('ExternalServices::Ldap.find_ldap_entry - Execution expired.')
    end
    entry
  end
  private :find_ldap_entry

  def server
    'directory.northwestern.edu'
  end
  private :server

  def port
    389
  end
  private :port

  def treebase
    'ou=People,dc=northwestern,dc=edu'
  end
  private :treebase

  ##
  # For each attribute retrieved, clean the value
  # @see clean_ldap_value
  # @param [Net::LDAP::Entry]
  # @retrun [Net::LDAP::Entry]
  def clean_ldap_entry(entry)
    ATTRIBUTES.each do |key|
      entry[key] = clean_ldap_value(entry[key])
    end
    entry
  end
  private :clean_ldap_entry

  ##
  # Remove undesirable characters from the value retrieved
  # e.g. newline("\n"), '-', '[', ']'
  # or replace with a space
  # e.g. '$'
  # @param [String]
  # @return [String]
  def clean_ldap_value(val)
    return nil if val.nil?

    if val.kind_of?(Array)
      return nil if val.length == 0
      val = clean_ldap_value(val[0].to_s)
    else
      val = val.to_s
      replacement_characters.each do |char, new_val|
        val = val.gsub(char, new_val)
      end
      val = val.strip
    end
    val
  end
  private :clean_ldap_value

  def replacement_characters
    [
      ["\n", ''],
      ['-', ''],
      ['[', ''],
      [']', ''],
      ['$', ' ']
    ]
  end
  private :replacement_characters

end
