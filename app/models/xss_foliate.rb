module XssFoliate
  extend ActiveSupport::Concern

  included do
    before_validation do
      self.class.fields.each do |k,v|
        if self[k].is_a?(String)
          self.write_attribute k, Loofah.fragment(self[k]).scrub!(:strip).to_s
        end
      end
    end
  end
end
