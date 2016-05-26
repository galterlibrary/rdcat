require 'rails_helper'

RSpec.describe "organizations/index", :type => :view do
  before(:each) do
    assign(:organizations, [
      FactoryGirl.create(:organization)
    ])
  end

  it "renders a list of organizations" do
    render
  end
end
