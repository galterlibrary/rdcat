require 'rails_helper'

RSpec.describe "datasets/new", type: :view do
  before(:each) do
    assign(:dataset, FactoryGirl.build(:dataset))
  end

  it "renders new dataset form" do
    render

    assert_select "form[action=?][method=?]", datasets_path, "post" do
    end
  end
end
