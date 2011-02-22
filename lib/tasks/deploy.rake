require 'compass'
require 'compass/exec'
namespace :credibles do
  desc "Pre compiles assets"
  task :deploy => ['assets:compile', 'credibles:push_heroku']
  task :push_heroku do

  end
end
