require "rails_helper"

RSpec.describe CategoriesController, type: :routing do
  describe "routing" do

    it "routes to #suggestions" do
      expect(:get => "/categories/suggestions").to route_to(
        "categories#suggestions")
    end
  end
end
