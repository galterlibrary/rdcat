require 'rails_helper'

RSpec.describe "welcome/about.html.haml", type: :view do
  context '.about' do
    it 'has correct info' do
      render
      expect(rendered).to have_content("Motivation")
      expect(rendered).to have_content("Objectives")
      expect(rendered).to have_content("Future Work")
      expect(rendered).to have_content("Contributors")
      expect(rendered).to have_content("Support")
    end
  end
end