require 'rails_helper'

RSpec.describe "distributions/index", :type => :view do
  before(:each) do
    assign(:distributions, [
      Distribution.create!(),
      Distribution.create!()
    ])
  end

  it "renders a list of distributions" do
    render
  end
end
