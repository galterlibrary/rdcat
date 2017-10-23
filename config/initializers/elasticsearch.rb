config = {
  host: 'localhost:9200',
  log: true,
  logger: Rails.logger,
  transport_options: {
    request: { timeout: 5 },
  }
}

if File.exists?('config/elasticsearch.yml')
  config.merge!(
    YAML.load_file('config/elasticsearch.yml')[Rails.env].symbolize_keys
  )
end

Elasticsearch::Model.client = Elasticsearch::Client.new(config)
