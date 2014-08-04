# Working with this code
## Dependencies
This code has the following development/testing dependencies:
* PostgreSQL 9.2+ (currently deployed with 9.3.2) - the database
* PhantomJS - used to simulate javascript in the browser for testing
* NodeJS - the javascript execution engine (you be may be able to use a different JS execution engine with no problems, as we are not dependent on anything Node specific)

If you are developing on a Mac, I strongly recommend installing [homebrew](http://brew.sh/), since it makes installing dependencies such as these trivial.  Also, make sure to follow any instructions that show up when you install these dependencies with homebrew.

## Rubies
As of now, this code is tested using Ruby 2.1.1 and JRuby 1.7.10.  SRG's production deployment of EGTAOnline currently runs on JRuby 1.7.10 because it supports true parallelism via multi-threading.  This capability is primarily used for background processing, and because running a multi-threaded application server doesn't require holding multiple copies of the application in memory when serving multiple requests.  I also test with Ruby 2.1.1 (MRI) because JRuby is slow to launch a JVM, and for running unit tests and doing work in the rails console in development, it's really annoying waiting for a JVM to load.  I switch between these two rubies using [rbenv](https://github.com/sstephenson/rbenv).

Supporting these two flavors of Ruby means that for some functionality, such as JSON parsing, I need to install a different library for each Ruby.  See the [Gemfile](https://github.com/bcassell/egtaonline3/blob/master/Gemfile) to understand what I'm talking about here.

### JRuby tips
There are some quirks to working with JRuby.  For one, you may at some point get an error relating to cryptography.  This can be addressed by installing the [Java Cryptography Extension](http://www.oracle.com/technetwork/java/javase/downloads/jce-7-download-432124.html) as explained [here](http://suhothayan.blogspot.com/2012/05/how-to-install-java-cryptography.html).  You may also encounter a variety of memory related errors when running the test suite.  You can address this by setting JRuby options to more reasonable memory settings.  For my development machine, I put the following in my .zshrc (.bashrc equivalent for the zsh shell):

```
export JRUBY_OPTS="-J-Xmx8g -J-XX:MaxPermSize=128M"
```

# Getting the code and installing libraries
First things first, clone this repository:

```
git clone https://github.com/egtaonline/egtaonline3
```

Next, for each ruby, install [Bundler](http://bundler.io) with:

```
gem install bundler
```

If you are using rbenv, this should be followed with `rbenv rehash`.  Bundler ensures that you have all the ruby library dependencies met.  cd into the egtaonline3 director and run:

```
bundle install
```

to install all the required libraries.  Throughout these instructions, you will see commands that start with `bundle exec`.  This is to ensure the appropriate versions of libraries are loaded, in case you have installed other versions of these libraries in your system.

# Setting up the database
The simplest way to make everything work is to create a superuser in the database matching the application name.  Doing this will vary somewhat based on your operating system and Postgres install.  The key command is:

```
createuser -s egtaonline3
```

but you may need to execute this command as the postgres user, or as some other superuser, depending on your install.  Next create the databases with:

```
bundle exec rake db:create
psql -d egtaonline3\_development -f db/structure.sql
psql -d egtaonline3\_test -f db/structure.sql
```

Normally you would run the rake command to run migrations after creating the databases, but here we are first asking Postgres to run commands from the structure.sql file.  This is because many of the migrations were part of a migration from a previous database system and should not be run on your development machine.  The structure.sql will jumpstart your development and test databases to look like the databases did the last time someone ran rake db:structure:dump and pushed the output to github.  Since the structure.sql file may be out of date, we now run any migrations that have been committed since the last time structure.sql was updated:

```
bundle exec rake db:migrate
RAILS\_ENV=test bundle exec rake db:migrate
```

These commands should also be run whenever you have written a new migration, or you git pull a code update that has new migrations in it.

# Running the tests
If you've gotten this far, it's time to run the test suite to make sure everything has been set up correctly.  The test suite uses the [RSpec](http://rspec.info/) framework for writing and running tests.  To run all the tests:

```
bundle exec rspec spec
```

This indicates that rspec should run all of the tests in the spec folder.  If everything is green after you run the tests you are good to go!  If you have 1 or 2 errors, particularly errors having to do with float precision, you are probably still fine (though we should fix this eventually).

## Libraries
I've made extensive use of open source libraries to pull this project together.  Please read through the [Gemfile](https://github.com/bcassell/egtaonline3/blob/master/Gemfile) which is annotated to explain what each library is doing.  Nearly all of the libraries have their source and documentation on github.  Some of the libraries such as decent\_exposure and haml were convenience choices that make this project look a little different than a lot of the Rails tutorials out there.  I apologize for this, and if I had time I would definitely pull out decent_exposure, because it seems more confusing than necessary, especially for the games and schedulers controllers.  [Haml](http://haml.info/), however, probably has saved me a bunch of time over writing HTML.
