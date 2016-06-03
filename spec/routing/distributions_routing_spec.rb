require 'rails_helper'

RSpec.describe DistributionsController, type: :routing do
  describe 'routing' do


    it 'routes to #index' do
      expect(get: '/datasets/23/distributions').to route_to('distributions#index', dataset_id: '23')
    end

    it 'routes to #new' do
      expect(get: '/datasets/23/distributions/new').to route_to('distributions#new', dataset_id: '23')
    end

    it 'routes to #show' do
      expect(get: '/datasets/23/distributions/1').to route_to('distributions#show', id: '1', dataset_id: '23')
    end

    it 'routes to #edit' do
      expect(get: '/datasets/23/distributions/1/edit').to route_to('distributions#edit', id: '1', dataset_id: '23')
    end

    it 'routes to #create' do
      expect(post: '/datasets/23/distributions').to route_to('distributions#create', dataset_id: '23')
    end

    it 'routes to #update' do
      expect(put: '/datasets/23/distributions/1').to route_to('distributions#update', id: '1', dataset_id: '23')
    end

    it 'routes to #destroy' do
      expect(delete: '/datasets/23/distributions/1').to route_to('distributions#destroy', id: '1', dataset_id: '23')
    end

  end
end
