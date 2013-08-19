namespace :foreman do
  # desc "Export the Procfile to Ubuntu's upstart scripts"
  # task :export, :roles => :app do
  #   run "cd /home/#{user}/#{application}/current && rbenv #{sudo} bundle exec foreman export upstart /etc/init -a sidekiq -u #{user} -l /var/#{application}/log"
  # end

  desc "Start the application services"
  task :start, :roles => :app do
    run "#{sudo} start sidekiq"
  end

  desc "Stop the application services"
  task :stop, :roles => :app do
    run "#{sudo} stop sidekiq"
  end

  desc "Restart the application services"
  task :restart, :roles => :app do
    run "#{sudo} start sidekiq || #{sudo} restart sidekiq"
  end
end

after "deploy:update", "foreman:export"
after "deploy:update", "foreman:restart"