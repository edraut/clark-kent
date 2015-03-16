module ClarkKent
  class ResourceOption
    attr_accessor :id, :name

    def initialize params = {}
      params.each { |key, value| send "#{key}=", value }
    end

  end
end