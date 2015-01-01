module Relational
  module Audit
    module ControllerMethods

      module InstanceMethods

        def self.included(base)
          base.before_filter :audit_set_changes_by
        end

        def audit_set_changes_by
          ::Relational::Audit.audit_changes_by = current_user if defined? current_user
          ::Relational::Audit.audit_transaction_id = SecureRandom.hex(10)
        end

      end

    end
  end
end