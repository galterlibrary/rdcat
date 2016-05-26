require 'rails_helper'

RSpec.describe "organizations/show", :type => :view do
  before(:each) do
    @organization = assign(:organization, FactoryGirl.create(:organization))
  end

  it "renders attributes in <p>" do
    render
  end
end
