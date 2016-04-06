### Accept rvm key

$ - gpg --keyserver hkp://keys.gnupg.net --recv-keys 

409B6B1796C275462A1703113804BB82D39DC0E3

### Install Ruby

$ \curl -sSL https://get.rvm.io | bash -s stable --ruby=2.2.1

### Clone my repo

$ git clone https://github.com/keerin/accountables.git

### Move into project folder and install bundler

$ cd /accountables; gem install bundler

### Set up all gems according to gemfile

$ bundle install

### Intro to Sinatra directory and file structure

 * .bundle - directors which allows you to set a config file so only dev-related gems are installed.
 * db - Directory for my sqlite3 database.
 * project plans - my own plans and to do lists, should be added to .gitignore.
 * public - This is where Sinatra looks for css and other assets like your images or JS.
 * views - Defaul directory for Sinatra apps to store html (or templated) markup files. I use haml.
 * .env - tried to create a .env file to store environment variables, but apparently this is the wrong approach - still learning.
 * Gemfile - This contains all the gems my project relies on. I;ve grouped them as core app, ORM, security then dev and prod groups.
 * Gemfile.lock - Bundler creates this file to indicate version of gems etc used and the source for each
 * Heroku requires this - https://devcenter.heroku.com/articles/getting-started-with-ruby-o#declare-process-types-with-procfile
 * app.rb - This is the meat and potatoes. Most Sinatra apps are all in one file. I chose to subclass the app, in case I needed to rely on middleware from anywhere. I can explain this later, but you will see I set up the app logic in class Accountables < Sinatra::Base - this means my class inherits the sinatra base classes. Extra stuff I have to add in as I need it. Done this so I could learn more really.
 * config.ru - Sinatra is a Rack app (Rails is too, actually). Rack is a Ruby webserver interface. Because I am subclassing my app in Sinatra::Base, I have to include a config file for Rack.
 * logs.txt - I just piped the Heroku run logs to a text file and commited them by accident
 * model.rb - my database model set up. I use an ORM called DataMapper. Very easy to use.
 * warden.rb - This was in my main app.rb code, but I separated it out to be more concise. This should be straightforward to read and figure out even if you know no Ruby.

### Run the app

$ shotgun config.ru

Open 127.0.0.1:9393 (or whatever port Shotgun runs on)

Shotgun is used because it reloads automatically when the code changes. The standard method would be:

$ bundle exec rackup

Which will require a restart of the server to see any code changes.

Run the app. Don't laugh at obvious bugs :)

### Contributing

Can you open issues on Github for bugs you find? I will be doing this for my own sake. Be good if you could as well.
