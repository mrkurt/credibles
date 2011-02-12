class Account
  include Mongoid::Document
  include Mongoid::Timestamps

  references_many :pages
  references_many :edits

  field :hosts, :type => Array
  index :hosts, :unique => true
end
