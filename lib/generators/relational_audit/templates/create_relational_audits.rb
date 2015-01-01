class CreateRelationalAudits < ActiveRecord::Migration
  def change
    create_table :audits do |t|
      t.string :entity_type, :null => false
      t.integer :entity_id, :null => false
      t.string :event, :null => false
      t.string :changes_by
      t.text :entity_changes
      t.string :transaction_id
      t.datetime :created_at
    end

    create_table :audit_relations do |t|
      t.integer :audit_id
      t.string :relation_type
      t.integer :relation_id
      t.datetime :created_at
    end

    add_index :audits, [:entity_type, :entity_id]
    add_index :audit_relations, [:audit_id, :relation_id]
  end
end
