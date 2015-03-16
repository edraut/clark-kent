module ClarkKent
  module Cloneable
    def cloneable_attributes
      these_attrs = self.attributes.dup
      these_attrs.delete('id')
      these_attrs.delete('created_at')
      these_attrs.delete('updated_at')
      these_attrs
    end

    def reset_timestamps
      updated_at = nil
      created_at = nil
      self
    end

  end
end