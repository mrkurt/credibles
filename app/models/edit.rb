class Edit
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning
  include XssFoliate

  referenced_in :page
  referenced_in :account

  #user fields
  field :url
  field :ip_address
  embeds_many :suggestions, :class_name => 'Edit::Suggestion', :inverse_of => :edit
  field :comments, :xss_foliate => :strip
  validates_presence_of :comments, :unless => :has_suggestions?, :message => "can't be blank unless you've made changes"

  #editor fields
  field :key
  field :editor_notes
  field :status, :default => 'new'
  validates :status, :inclusion => ['new', 'good', 'bad', 'neutral']

  before_validation do
    self.account_id = page.account_id unless account_id || page.nil?
    self.key = ActiveSupport::SecureRandom.hex(6) if key.blank?
  end

  def has_suggestions?
    suggestions.select(&:is_unchanged?).each(&:destroy)
    suggestions.length > 0
  end

  class Suggestion
    include Mongoid::Document
    include XssFoliate

    field :element_path
    field :original
    field :proposed
    field :distance, :type => Integer
    before_validation do
      if distance.nil? || changes['original'] || changes['proposed']
        self.distance = Text::Levenshtein.distance(original || '', proposed || '')
      end
    end

    embedded_in :edit

    def is_unchanged?
      original == proposed
    end
  end
end
