module ElasticsearchConcerns
  extend ActiveSupport::Concern

  included do
    def self.elastic_suggest(prefix, suggest_name, size=10)
      __elasticsearch__.search({
        suggest: {
          suggest_name => {
            prefix: prefix,
            completion: {
              field: 'suggest',
              size: size
            }
          }
        }
      })
    end

    def self.reindex!
      begin
        __elasticsearch__.delete_index!
      rescue Elasticsearch::Transport::Transport::Errors::NotFound
      end
      __elasticsearch__.create_index!
      import
    end
  end
end


