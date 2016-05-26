require 'rails_helper'

RSpec.describe "distributions/edit", type: :view do
  before(:each) do
    @distribution = assign(:distribution, FactoryGirl.create(:distribution))
  end

  it "renders the edit distribution form" do
    render

    assert_select "form[action=?][method=?]", distribution_path(@distribution), "post" do
    end
  end
end
