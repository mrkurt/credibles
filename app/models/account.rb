class Account
  include Mongoid::Document
  include Mongoid::Timestamps

  references_many :pages
  references_many :edits

  field :hosts, :type => Array
  index :hosts, :unique => true

  field :key
  index :key, :unique => true
  before_validation do
    self.key = id.to_s if key.blank?
  end
end
