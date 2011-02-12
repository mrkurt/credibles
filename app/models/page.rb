class Page
  include Mongoid::Document
  include Mongoid::Timestamps

  references_many :edits
  referenced_in :account

  field :key
  field :url

  key :account_id, :key
end
