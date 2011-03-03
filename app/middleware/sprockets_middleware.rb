class SprocketsMiddleware
  ASSET_PATHS = ['/javascripts/', '/stylesheets/', '/images/']

  class << self
    def environment
      @environment ||= Sprockets::Environment.new.tap do |e|
        e.paths.push 'server'
      end
    end
    
    def server
      @server ||= Sprockets::Server.new(environment)
    end

    def version_stamp(asset_path)
      a = environment.find_asset(asset_path)
      if a
        asset_path = "#{asset_path}?#{a.digest}"
      end
      asset_path
    end
  end

  attr_accessor :app
  def initialize(app)
    self.app = app
  end

  def call(env)
    if is_asset?(env['PATH_INFO'])
      self.class.server.call(env)
    else
      app.call(env)
    end
  end

  def is_asset?(path)
    ASSET_PATHS.detect do |p|
      path.starts_with?(p)
    end
  end
end
