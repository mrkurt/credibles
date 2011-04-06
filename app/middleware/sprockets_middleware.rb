class SprocketsMiddleware
  ASSET_PATHS = ['/javascripts/', '/stylesheets/', '/images/']

  class << self
    def environment
      @environment ||= Sprockets::Environment.new.tap do |e|
        e.paths.push 'server', 'vendor'
        #e.logger = Rails.logger
      end
    end

    def version_stamp(asset_path)
      if Rails.env == 'development'
        environment.instance_variable_set('@cache', {})
      end
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
      if Rails.env == 'development'
        self.class.environment.instance_variable_set('@cache', {})
      end
      results = self.class.environment.call(env)
      Rails.logger.info "Served #{env['PATH_INFO']} with Sprockets (#{results.first})"
      results
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
