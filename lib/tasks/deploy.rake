require 'compass'
require 'compass/exec'
namespace :credibles do
  desc "Pre compiles assets"
  task :deploy => ['credibles:push_heroku']
  task :push_heroku do
    system 'git push heroku master'
  end
end
