require 'compass'
require 'compass/exec'
namespace :credibles do
  desc "Pre compiles assets"
  task :deploy => ['assets:compile', 'credibles:push_heroku']
  task :push_heroku do
    system "git checkout -b staging || git checkout staging"
    system 'git remote add heroku git@heroku.com:credibles.git || echo "remote exists"'
    system 'git pull heroku master'
    system "git add -f public/stylesheets/*.css"
    system "git add -f public/javascripts/*.js"
    system 'git commit -m "Updating compiled assets" || echo "No asset changes"'
    system 'git push heroku master'

    system 'git checkout master'
  end
end
