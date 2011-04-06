guard 'spork', :wait => 60 do
  watch(%r{config/application\.rb})
  watch(%r{config/environment\.rb})
  watch(%r{^config/environments/.*\.rb$})
  watch(%r{^config/initializers/.*\.rb$})
  watch(%r{spec/spec_helper\.rb})
end

guard 'rspec', :version => 2, :cli => "--color --format nested --fail-fast --drb", :bundler => false do
  watch(%r{^spec/(.*)_spec\.rb})
  watch(%r{^lib/(.*)\.rb})                              { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^spec/spec_helper.rb})                       { "spec" }
  
  # Rails example
  watch(%r{^app/(.*)\.rb})                              { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/views/(.*)/.*$})                     { |m| "spec/acceptance/#{m[1]}_spec.rb" }
  watch(%r{^app/controllers/(.*)_controller\.rb*$})   { |m| "spec/acceptance/#{m[1]}_spec.rb" }
  # watch(%r{^lib/(.*)\.rb})                              { |m| "spec/lib/#{m[1]}_spec.rb" }
  #watch(%r{^config/routes.rb})                          { "spec/routing" }
  watch(%r{^app/controllers/application_controller.rb}) { "spec/controllers" }
  watch(%r{^spec/factories.rb})                         { "spec/models" }
end
