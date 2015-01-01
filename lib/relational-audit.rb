require 'relational/audit.rb'
require 'relational/controller_methods.rb'
require 'pry'

ActiveRecord::Base.send :extend, Relational::Audit::ClassMethod
ActiveRecord::Base.send :include, Relational::Audit::InstanceMethod

if defined?(::ActionController)
  ::ActiveSupport.on_load(:action_controller) { include Relational::Audit::ControllerMethods::InstanceMethods }
end


module RelationalAudit
  class Audit < ActiveRecord::Base
    has_many :audit_relations

    def changeset
      YAML::load(self.entity_changes)
    end
  end

  class AuditRelation < ActiveRecord::Base
    belongs_to :audit
  end
end