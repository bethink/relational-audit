require "relational/audit/version"
require 'securerandom'

module Relational
  module Audit

    @@audit_changes_by = nil

    def self.audit_changes_by=(user)
      @@audit_changes_by = user
    end

    def self.audit_changes_by
      @@audit_changes_by
    end

    @@audit_transaction_id = nil

    def self.audit_transaction_id=(user)
      @@audit_transaction_id = user
    end

    def self.audit_transaction_id
      @@audit_transaction_id
    end

    module Event
      CREATE = 'C'
      UPDATE = 'U'
      DESTROY = 'D'
    end

    module InstanceMethod

      def raw_audits
        ::RelationalAudit::Audit.joins('join audit_relations on audits.id = audit_relations.audit_id').where("audit_relations.relation_type = ? and audit_relations.relation_id = ?", self.class.name, self.id)
      end

      def audits(order='DESC')
        grouped_audits = {}
        self.raw_audits.order("id #{order}").each do |audit|
          grouped_audits[audit.transaction_id] ||= []
          grouped_audits[audit.transaction_id] << audit
        end

        entity_audits = grouped_audits.collect do |transaction_id, audits|
          unless audits.blank?
            merged_audit = {:changes_by => audits.first.changes_by, :changes => {}}
            audits.each do |audit|
              merged_audit[:changes].merge!(audit.changeset)
            end
            merged_audit
          end
        end.compact

        entity_audits
      end

      def add_created_relational_audit
        add_audit(::Relational::Audit::Event::CREATE, [self])
      end

      def add_updated_relational_audit
        add_audit(::Relational::Audit::Event::UPDATE, [self])
      end

      def add_destroyed_relational_audit
        add_audit(::Relational::Audit::Event::DESTROY, [self])
      end

      def add_audit event_type, related_to

        hash_changes = self.changes

        options = self.class.audit_options

        unless options[:only].blank?
          hash_changes.delete_if { |key, value| !options[:only].include?(key.intern) }
        end

        unless options[:ignore].blank?
          hash_changes.delete_if { |key, value| options[:ignore].include?(key.intern) }
        end

        return if hash_changes.blank?

        serialized_changes = YAML::dump hash_changes

        audit = ::RelationalAudit::Audit.new(
            :entity_type => self.class.name,
            :entity_id => self.id,
            :entity_changes => serialized_changes,
            :changes_by => ::Relational::Audit.audit_changes_by,
            :event => event_type,
            :transaction_id => ::Relational::Audit::audit_transaction_id
        )

        related_to.each do |entity|
          audit.audit_relations.build(
              :relation_type => entity.class.name,
              :relation_id => entity.id
          )
        end

        audit.save
      end

      def add_child_audit(event_type)
        related_to = self.class.audit_entities.collect do |entity|
          self.send(entity)
        end
        related_to.push(self)

        add_audit(event_type, related_to.compact)
      end

      def add_created_child_audit
        self.add_child_audit(::Relational::Audit::Event::CREATE)
      end

      def add_updated_child_audit
        self.add_child_audit(::Relational::Audit::Event::UPDATE)
      end

      def add_destroyed_child_audit
        self.add_child_audit(::Relational::Audit::Event::DESTROY)
      end

    end

    module ClassMethod

      def audit_entities
        self.class_variable_get :@@audit_entities
      end

      def audit_entities=(audit_entities)
        self.class_variable_set :@@audit_entities, (audit_entities.is_a?(Array) ? audit_entities : [audit_entities])
      end

      def audit_options
        self.class_variable_get :@@audit_options
      end

      def audit_options=(audit_options)
        self.class_variable_set :@@audit_options, audit_options
      end

      def relational_audit audit_options={}
        self.audit_options = audit_options unless audit_options.blank?

        after_create :add_created_relational_audit
        after_update :add_updated_relational_audit
        after_destroy :add_destroyed_relational_audit
      end

      def belongs_to_audit audit_entities, audit_options={}
        self.audit_entities = audit_entities
        self.audit_options = audit_options unless audit_options.blank?

        after_create :add_created_child_audit
        after_update :add_updated_child_audit
        after_destroy :add_destroyed_child_audit
      end

    end

  end
end
