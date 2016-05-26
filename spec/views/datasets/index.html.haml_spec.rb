require 'rails_helper'

RSpec.describe "datasets/index", type: :view do
  before(:each) do
    assign(:datasets, [
      FactoryGirl.create(:dataset)
    ])
  end

  it "renders a list of datasets" do
    render
  end
end
