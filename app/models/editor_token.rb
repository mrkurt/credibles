class EditorToken
  include Mongoid::Document
  include Mongoid::Timestamps

  referenced_in :account
  validates_presence_of :account_id

  field :key
  validates_uniqueness_of :key
  index :key, :unique => true

  field :for
  field :use_count, :type => Integer, :default => 0

  before_validation do
    self.key = ActiveSupport::SecureRandom.hex(25) if key.nil?
  end
end
