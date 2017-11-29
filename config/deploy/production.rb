set :stage, :production
set :rails_env, :production

set :rvm_ruby_version, "#{ APP_CONFIG['ruby_version'] }@rdcat"

server APP_CONFIG['production']['app_host'],
       'user' => 'deploy',
       'roles' => %w{web app db},
       'primary' => true

role :app, APP_CONFIG['production']['app_host']
role :web, APP_CONFIG['production']['app_host']
role :db,  APP_CONFIG['production']['app_host']
