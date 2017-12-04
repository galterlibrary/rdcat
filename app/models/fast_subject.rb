# == Schema Information
#
# Table name: fast_subjects
#
#  id         :integer          not null, primary key
#  label      :string
#  identifier :string
#

class FastSubject < ApplicationRecord
  validates :label, presence: true
end
