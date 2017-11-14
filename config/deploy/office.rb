set :stage, :office
set :rails_env, :staging

set :rvm_ruby_version, '2.4.2@rdcat'

server '192.168.122.80',
       user: 'deploy',
       roles: %w{app db web migrator}
set :ssh_options, {
    :proxy => Net::SSH::Proxy::Command.new('ssh deploy@165.124.124.30 -W %h:%p'),      :forward_agent => true
}
