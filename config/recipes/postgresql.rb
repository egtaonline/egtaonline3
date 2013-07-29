set_default(:postgresql_host, "localhost")
set_default(:postgresql_user) { application }
set_default(:postgresql_password) { Capistrano::CLI.password_prompt "PostgreSQL Password: " }
set_default(:postgresql_database) { "#{application}_production" }

namespace :postgresql do
  desc "Install the latest stable release of PostgreSQL."
  task :install, roles: :db, only: {primary: true} do
    # Get a more recent version of postgresql
    dotdeb = <<-DOTDEB
               deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main
             DOTDEB
    put dotdeb,"/tmp/dotdeb"
    run "#{sudo} mv /tmp/dotdeb /etc/apt/sources.list.d/pgdg.list"
    run "wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | #{sudo} apt-key add -"
    run "#{sudo} apt-get update"
    run "#{sudo} apt-get -y install postgresql pgadmin3 postgresql-client postgresql-contrib postgresql-server-dev libpq-dev"
  end
  after "deploy:install", "postgresql:install"

  desc "Create a database for this application."
  task :create_database, roles: :db, only: {primary: true} do
    run %Q{#{sudo} -u postgres psql -c "create user #{postgresql_user} with password '#{postgresql_password}';"}
    run %Q{#{sudo} -u postgres psql -c "create database #{postgresql_database} owner #{postgresql_user};"}
  end
  after "deploy:setup", "postgresql:create_database"

  desc "Generate the database.yml configuration file."
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "postgresql.yml.erb", "#{shared_path}/config/database.yml"
  end
  after "deploy:setup", "postgresql:setup"

  desc "Symlink the database.yml file into latest release"
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after "deploy:finalize_update", "postgresql:symlink"
end