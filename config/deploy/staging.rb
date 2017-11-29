set :stage, :staging
set :rails_env, :staging

set :rvm_ruby_version, "#{ APP_CONFIG['ruby_version'] }@rdcat"

server APP_CONFIG['staging']['app_host'],
       'user' => 'deploy',
       'roles' => %w{web app},
       'primary' => true

role :app, APP_CONFIG['staging']['app_host']
role :web, APP_CONFIG['staging']['app_host']
role :db,  APP_CONFIG['staging']['app_host']
