namespace :credibles do
  desc "Pre compiles assets"
  task :compile do
    s_env = Sprockets::Environment.new
    s_env.paths << 'server'
    puts s_env
  end
end
