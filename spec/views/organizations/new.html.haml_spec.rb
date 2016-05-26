require 'rails_helper'

RSpec.describe "organizations/new", :type => :view do
  before(:each) do
    assign(:organization, FactoryGirl.build(:organization))
  end

  it "renders new organization form" do
    render

    assert_select "form[action=?][method=?]", organizations_path, "post" do
    end
  end
end
