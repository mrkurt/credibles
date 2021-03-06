class Edit
  EDIT_STATUS_OPTIONS = ['new', 'accepted', 'closed', 'irrelevant']
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning
  include XssFoliate

  referenced_in :page
  index :page_id

  referenced_in :account
  index :account_id

  #user fields
  field :email
  field :opt_in, :type => Boolean, :default => false
  field :url
  field :ip_address
  embeds_many :suggestions, :class_name => 'Edit::Suggestion', :inverse_of => :edit

  field :comments, :xss_foliate => :strip
  validates_presence_of :comments, :unless => :has_suggestions?, :message => "can't be blank unless you've made changes"

  #editor fields
  field :key
  field :editor_notes
  field :distance, :type => Integer, :default => 0
  field :status, :default => 'new'
  validates :status, :inclusion => EDIT_STATUS_OPTIONS

  before_validation do
    self.account_id = page.account_id unless account_id || page.nil?
    self.key = ActiveSupport::SecureRandom.hex(6) if key.blank?
  end

  before_save do
    suggestions.select(&:is_unchanged?).each(&:destroy)
    self.distance = suggestions.inject(0){|acc, s| acc + s.distance}
    true
  end

  after_create do
    Resque.enqueue(EditWorker, 'create', self.id)
  end

  after_save do
    c = previous_changes
    status = c['status']
    msg = c['editor_notes'].last if c['editor_notes'].is_a?(Array)
    Resque.enqueue(EditWorker, 'change', self.id, status, msg) if status || msg
  end

  def has_suggestions?
    suggestions.reject(&:is_unchanged?).length > 0
  end

  def add_suggestions(params)
    params = [params] unless params.is_a?(Array)
    params.each do |p|
      self.suggestions << Edit::Suggestion.new(p)
    end
    self.suggestions
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
