require 'rails_helper'

RSpec.describe "Distributions", type: :request, elasticsearch: true do

  let(:dataset) { FactoryGirl.create(:dataset) }

  context 'without a logged in user' do 
    describe "GET /datasets/:dataset_id/distributions" do
      it "returns a 302" do
        get dataset_distributions_path(dataset)
        expect(response).to have_http_status(302)
      end
    end
  end

  context 'with a logged in user' do 
    describe "GET /datasets/:dataset_id/distributions" do
      it "returns a 200" do
        user = FactoryGirl.create(:user)
        login_as user

        get dataset_distributions_path(dataset)
        expect(response).to have_http_status(200)
      end
    end
  end

end
