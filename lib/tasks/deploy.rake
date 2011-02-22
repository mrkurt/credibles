require 'compass'
require 'compass/exec'
namespace :credibles do
  desc "Pre compiles assets"
  task :deploy => ['credibles:prep_heroku', 'assets:compile', 'credibles:push_heroku']
  task :prep_heroku do
    puts "Switching to staging branch...\n"
    system "git checkout -b staging || git checkout staging"
    puts "Checking heroku remote...\n"
    system 'git remote add heroku git@heroku.com:credibles.git || echo "remote exists"'
    puts "Pulling down heroku changes...\n"
    system 'git pull heroku master'
  end
  task :push_heroku do
    puts "Adding changed files..."
    system "git add -f public/stylesheets/*.css"
    system "git add -f public/javascripts/*.js"
    puts "Committing changes..."
    system 'git commit -m "Updating compiled assets" || echo "No asset changes"'
    puts "Pushing..."
    system 'git push heroku staging:master'

    puts "Switching back to master..."
    system 'git checkout master'
  end
end
