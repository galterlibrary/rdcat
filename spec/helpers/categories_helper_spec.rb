require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the CategoriesHelper. For example:
#
# describe CategoriesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe CategoriesHelper, type: :helper do

  it 'is included in the helper object' do
    included_modules = (class << helper; self; end).send :included_modules
    expect(included_modules).to include(CategoriesHelper)
  end

end
