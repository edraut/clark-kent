module ClarkKent
  class SharingScopeKind
    attr_accessor :type, :name, :human_name, :class_name, :user_association

    def self.all
      return @ss_types if @ss_types
      user_ss = self.new(ClarkKent.user_class_name)
      @ss_types = [user_ss]
      ClarkKent.other_sharing_scopes.each do |ss_type|
        @ss_types << self.new(*ss_type)
      end
      @ss_types << self.new('Everyone')
      @ss_types
    end

    def self.find_by_class_name(klass_name)
      self.all.detect{|ssk| klass_name == ssk.class_name}
    end

    def self.has_some(thing)
      if thing.present?
        if thing.respond_to? :any?
          thing.any?
        else
          true
        end
      else
        false
      end
    end

    def self.custom
      all.select{|ssk| ['everyone','personal'].exclude? ssk.type}
    end

    def self.custom_for_user(user)
      custom.select{|ssk| has_some(ssk.associated_containers_for(user)) }
    end

    def self.select_options
      return @sharing_scope_options if @sharing_scope_options
      @sharing_scope_options = {}
      self.all.each do |sharing_scope_kind|
        @sharing_scope_options[sharing_scope_kind.human_name] = sharing_scope_kind.class_name
      end
      @sharing_scope_options
    end

    def self.select_options_for_user(user)
      sharing_scope_options = {}
      self.all.each do |sharing_scope_kind|
        if custom.exclude?(sharing_scope_kind) || has_some(sharing_scope_kind.associated_containers_for(user))
          sharing_scope_options[sharing_scope_kind.human_name] = sharing_scope_kind.class_name
        end
      end
      sharing_scope_options
    end

    def initialize(class_name,user_association = nil)
      if 'Everyone' == class_name
        @class_name = ''
        @human_name = 'Everyone'
      else
        @class_name = class_name
      end
      @user_association = user_association
    end

    def human_name
      return @human_name if @human_name.present?
      if @class_name == ClarkKent.user_class_name
        @human_name = 'Personal'
      else
        @human_name = @class_name.humanize
      end
      @human_name
    end

    def type
      human_name.gsub(' ','_').downcase
    end

    def basic_association_id_collection_name
      (class_name.underscore + '_ids').to_sym
    end

    def associated_containers_for(user)
      user.send @user_association
    end

    def scopes_for(user)
      case type
      when 'everyone'
        [ClarkKent::SharingScope.new('Everyone',self)]
      when 'personal'
        [ClarkKent::SharingScope.new(user,self)]
      else
        if associated_containers_for(user).respond_to? :map
          associated_containers_for(user).map do |associated_container|
            ClarkKent::SharingScope.new(associated_container,self)
          end
        else
          if associated_containers_for(user).present?
            [ClarkKent::SharingScope.new(associated_containers_for(user),self)]
          else
            []
          end
        end
      end
    end

  end
end