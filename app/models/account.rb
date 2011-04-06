class Account
  include Mongoid::Document
  include Mongoid::Timestamps

  references_many :pages
  references_many :edits
  references_many :editor_tokens

  field :hosts, :type => Array, :default => []
  index :hosts, :unique => true

  field :editors, :type => Array, :default => []
  field :owner_email
  field :edit_url_format

  field :key
  index :key, :unique => true
  before_validation do
    self.key = id.to_s if key.blank?
  end

  def self.find_by_editor_token(key)
    t = EditorToken.where(:key => key.to_s).first
    if t.nil?
      nil
    else
      t.inc :use_count, 1
      t.account
    end
  end
end
