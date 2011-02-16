class ApplicationWorker
  def self.perform(*args)
    m = args.shift
    send(m, *args)
  end
end
