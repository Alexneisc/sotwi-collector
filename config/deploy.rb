# config valid only for current version of Capistrano
lock '3.9.0'

set :application, 'sotwi-collector'
set :user, 'deploy'
set :repo_url, 'git@bitbucket.org:alexneisc/sotwi-collector.git'

set :rvm_type, :user
set :rvm_ruby_version, '2.4.1@sotwi-collector'
set :rack_env, :production

append :linked_files, 'config/twitter.rb'
append :linked_dirs, 'log', 'tmp/pids', 'tmp/sockets'

set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :ssh_options,     { forward_agent: true, user: fetch(:user) }

namespace :sidekiq do
  task :quiet do
    on roles(:app) do
      puts capture("pgrep -f 'sidekiq' | xargs kill -TSTP")
    end
  end
  task :restart do
    on roles(:app) do
      execute :sudo, :initctl, :restart, :workers
    end
  end
end

after 'deploy:starting', 'sidekiq:quiet'
after 'deploy:reverted', 'sidekiq:restart'
after 'deploy:published', 'sidekiq:restart'

# namespace :sotwi_collector_daemon do
#   task :restart do
#     on roles(:app) do
#       within release_path do
#         with rack_env: fetch(:rack_env) do
#           execute :bundle, "exec ruby sotwi-collector-daemon.rb restart"
#         end
#       end
#     end
#   end
# end

# namespace :deploy do
#   after :finishing, 'sotwi_collector_daemon:restart'
# end


#
# namespace :customs do
#   desc "Run Migrations"
#   task :migrations do
#     on roles(:app) do
#       within release_path do
#         with rack_env: fetch(:rack_env) do
#           execute :rake, "db:migrate"
#         end
#       end
#     end
#   end
# end
#
# namespace :thin_server do
#   desc "Start the Thin processes"
#   task :start do
#     on roles(:app) do
#       within release_path do
#         with rack_env: fetch(:rack_env) do
#           execute :bundle, "exec thin -C config/thin.yml -d -P #{fetch(:thin_pid)} start"
#         end
#       end
#     end
#   end
#
#   desc "Stop the Thin processes"
#   task :stop do
#     on roles(:app) do
#       within release_path do
#         with rack_env: fetch(:rack_env) do
#           execute "if [ -f #{fetch(:thin_pid)} ] && [ -e /proc/$(cat #{fetch(:thin_pid)}) ]; then kill -9 `cat #{fetch(:thin_pid)}`; fi"
#         end
#       end
#     end
#   end
#
#   desc "Restart private_pub server"
#   task :restart do
#     on roles(:app) do
#       invoke 'thin_server:stop'
#       invoke 'thin_server:start'
#     end
#   end
# end
#
# namespace :deploy do
#   after :finishing, 'customs:migrations'
#   after :finishing, 'thin_server:start'
# end
