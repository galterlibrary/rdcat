require 'rails_helper'

RSpec.describe "Distributions", type: :request do
  let(:dataset) { FactoryGirl.create(:dataset) }

  describe "GET /datasets/:dataset_id/distributions" do
    it "works! (now write some real specs)" do
      get dataset_distributions_path(dataset)
      expect(response).to have_http_status(200)
    end
  end
end
