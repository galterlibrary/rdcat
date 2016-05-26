require 'rails_helper'

RSpec.describe "distributions/new", :type => :view do
  before(:each) do
    assign(:distribution, Distribution.new())
  end

  it "renders new distribution form" do
    render

    assert_select "form[action=?][method=?]", distributions_path, "post" do
    end
  end
end
