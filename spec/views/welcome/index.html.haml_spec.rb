require 'rails_helper'

RSpec.describe "welcome/index.html.haml", type: :view do
  context '.welcome' do
    it 'has headers' do
      assign(:categories, ["Something"])
      render
      expect(rendered).to have_content("Galter DataCat")
      expect(rendered).to have_content("Feinberg School of Medicine Northwestern University")
      expect(rendered).to have_content("Explore Categories")
    end
    
    it 'has links to browse datasets and categories' do
      assign(:categories, ["Arm", "Leg"])
      render
      expect(rendered).to have_link("Browse Datasets", href: "/datasets")
      expect(rendered).to have_link("Arm", href: "/datasets?category=Arm")
      expect(rendered).to have_link("Leg", href: "/datasets?category=Leg")
    end
  end
end
