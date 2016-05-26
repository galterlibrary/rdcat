require "rails_helper"

RSpec.describe DistributionsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/distributions").to route_to("distributions#index")
    end

    it "routes to #new" do
      expect(:get => "/distributions/new").to route_to("distributions#new")
    end

    it "routes to #show" do
      expect(:get => "/distributions/1").to route_to("distributions#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/distributions/1/edit").to route_to("distributions#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/distributions").to route_to("distributions#create")
    end

    it "routes to #update" do
      expect(:put => "/distributions/1").to route_to("distributions#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/distributions/1").to route_to("distributions#destroy", :id => "1")
    end

  end
end
