set :application, 'strava-weather'
set :repo_url, 'git@github.com:zealot128/strava_weather_annotator.git'
set :rvm_ruby_version, '2.1.1'
set :rvm_type, :user

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_to, '/var/www/strava-weather/'
set :scm, :git

# set :format, :pretty
# set :log_level, :debug
set :pty, true

set :linked_files, %w{config/database.yml config/secrets.yml}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :keep_releases, 5

namespace :deploy do

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

  after :finishing, 'deploy:restart'
  after :finishing, 'deploy:cleanup'

end
