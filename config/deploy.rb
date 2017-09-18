# config valid only for current version of Capistrano
lock '3.9.0'

set :application, 'sotwi-collector'
set :user, 'deploy'
set :repo_url, 'git@bitbucket.org:alexneisc/sotwi-collector.git'

set :rvm_type, :user
set :rvm_ruby_version, '2.4.1@sotwi-collector'
set :rack_env, :production

append :linked_files, 'config/twitter.rb', 'config/sidekiq.rb', 'config/telegram.rb'
append :linked_dirs, 'log', 'tmp/pids', 'tmp/sockets'

set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :ssh_options,     { forward_agent: true, user: fetch(:user) }

namespace :sotwi_collector_daemon do
  task :restart do
    on roles(:app) do
      within release_path do
        with rack_env: fetch(:rack_env) do
          execute :bundle, "exec ruby sotwi-collector-daemon.rb restart"
        end
      end
    end
  end
end

namespace :deploy do
  after :finishing, 'sotwi_collector_daemon:restart'
end
