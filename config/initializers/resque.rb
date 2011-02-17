if Rails.env == 'test'
  Resque.redis.namespace = "resque:credibles:test" if Rails.env == 'test'
end

if Rails.env == 'production'
  uri = URI.parse(ENV["REDISTOGO_URL"])
  Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end
