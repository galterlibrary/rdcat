# config valid only for current version of Capistrano
lock '3.9.1'

APP_CONFIG = YAML.load(File.open('config/app_config.yml'))

set :application,  APP_CONFIG['application']
set :repo_url,     APP_CONFIG['repository']

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/www/apps/rdcat'
set :deploy_via, :copy

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system')
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets public/system}

# capistrano bundler properties
set :bundle_gemfile, -> { release_path.join('Gemfile') }
set :bundle_dir, -> { shared_path.join('bundle') }
set :bundle_flags, '--deployment --quiet'
set :bundle_without, %w{development test}.join(' ')
set :bundle_binstubs, -> { shared_path.join('bin') }
set :bundle_roles, :all

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

namespace :deploy do
  desc 'Restart application'
  task :db_seed do
    on roles(:web), in: :sequence, wait: 5 do
      within release_path do
        execute :bundle, :exec, :rails, 'db:seed'
      end
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  after :finishing, 'deploy:cleanup'

  task :httpd_graceful do
    on roles(:web), in: :sequence, wait: 5 do
      execute :sudo, "service httpd graceful"
    end
  end

end


namespace :deploy_prepare do
  desc 'Configure virtual host'
  task :passenger_mod do
    on roles(:web), in: :sequence, wait: 5 do
      if ENV['PASSENGER_MOD'] == 'true'
        within release_path do
          execute :bundle, :exec, 'passenger-install-apache2-module',
                  '--languages', "'ruby'", '-a'
        end
      else
        puts "!!! Skipping passenger mod installation (deploy_prepare:passenger_mod)"
        puts "Run with PASSENGER_MOD=true in the environment to enable"
      end
    end
  end

  desc 'Configure virtual host'
  task :create_vhost do
    on roles(:web), in: :sequence, wait: 5 do
      ssl_redirect = <<-EOF
Redirect permanent / https://#{ APP_CONFIG[ fetch(:stage).to_s ]['server_name'] }/
EOF
      common_httpd = <<-EOF
<IfModule mod_passenger.c>
    PassengerAppEnv #{ fetch(:rails_env) }
    PassengerRoot /var/www/apps/rdcat/shared/bundle/ruby/2.4.0/gems/passenger-5.1.11
    PassengerDefaultRuby /home/deploy/.rvm/wrappers/ruby-2.4.2@rdcat/ruby
    PassengerFriendlyErrorPages off
  </IfModule>

  DocumentRoot #{ fetch(:deploy_to) }/current/public
  RailsBaseURI /
  PassengerDebugLogFile /var/log/httpd/#{ fetch(:application) }_passenger.log

  <Location /admin >
    Order deny,allow
    Deny from all
    Allow from 129.105.0.0/16 165.124.0.0/16
  </Location>

  <Directory #{ fetch(:deploy_to) }/current/public >
    Allow from all
    Options -MultiViews
  </Directory>
EOF
      chain_file = <<-EOF
SSLCertificateChainFile #{ APP_CONFIG[ fetch(:stage).to_s ]['chain_file'] }
EOF
      vhost_config = <<-EOF
ServerName #{ APP_CONFIG[ fetch(:stage).to_s ]['server_name'] }

LoadModule passenger_module /var/www/apps/rdcat/shared/bundle/ruby/2.4.0/gems/passenger-5.1.11/buildout/apache2/mod_passenger.so

<VirtualHost *:80>
  #{ fetch(:stage).to_s == 'office' ? common_httpd : ssl_redirect }
</VirtualHost>

<VirtualHost *:443>
  SSLEngine On
  SSLCertificateFile #{ APP_CONFIG[ fetch(:stage).to_s ]['cert_file'] }
  #{ fetch(:stage).to_s == 'office' ? '' : chain_file }
  SSLCertificateKeyFile #{ APP_CONFIG[ fetch(:stage).to_s ]['key_file'] }
  #{ common_httpd }
</VirtualHost>
EOF
      execute :echo, "\"#{ vhost_config }\"", '|',
              :sudo, :tee, "/etc/httpd/conf.d/#{ fetch(:application) }.conf"
    end
  end
end

after "deploy:updated", "deploy:cleanup"
after "deploy:finished", "deploy_prepare:create_vhost"
after "deploy_prepare:create_vhost", "deploy_prepare:passenger_mod"
after "deploy_prepare:passenger_mod", "deploy:httpd_graceful"
after "deploy:httpd_graceful", "deploy:restart"
