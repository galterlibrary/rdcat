require 'rails_helper'

RSpec.describe "distributions/show", type: :view do
  before(:each) do
    @distribution = assign(:distribution, FactoryGirl.create(:distribution))
  end

  it "renders attributes in <p>" do
    render
  end
end