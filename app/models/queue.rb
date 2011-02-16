class Queue
  def self.beankstalk
    @beanstalk ||= Beanstalk::Pool.new(%w(localhost:11300))
  end
  def self.beanstalk=(bs)
    @beanstalk = bs
  end
end
