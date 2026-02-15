# frozen_string_literal: true

class LimitMysqlIndexKeyLength < ActiveRecord::Migration[8.1]
  def up
    return unless mysql?

    change_column :users, :firebase_uid, :string, limit: 191, null: false

    remove_index :active_storage_blobs, name: "index_active_storage_blobs_on_key"
    add_index :active_storage_blobs, :key, unique: true, length: 191, name: "index_active_storage_blobs_on_key"

    remove_index :active_storage_attachments, name: "index_active_storage_attachments_uniqueness"
    add_index :active_storage_attachments,
              %i[record_type record_id name blob_id],
              name: "index_active_storage_attachments_uniqueness",
              unique: true,
              length: { record_type: 191, name: 191 }

    remove_foreign_key :active_storage_variant_records, :active_storage_blobs
    remove_index :active_storage_variant_records, name: "index_active_storage_variant_records_uniqueness"
    add_index :active_storage_variant_records,
              %i[blob_id variation_digest],
              name: "index_active_storage_variant_records_uniqueness",
              unique: true,
              length: { variation_digest: 191 }
    add_foreign_key :active_storage_variant_records, :active_storage_blobs, column: :blob_id
  end

  def down
    return unless mysql?

    change_column :users, :firebase_uid, :string, limit: 255, null: false

    remove_index :active_storage_blobs, name: "index_active_storage_blobs_on_key"
    add_index :active_storage_blobs, :key, unique: true, name: "index_active_storage_blobs_on_key"

    remove_index :active_storage_attachments, name: "index_active_storage_attachments_uniqueness"
    add_index :active_storage_attachments,
              %i[record_type record_id name blob_id],
              name: "index_active_storage_attachments_uniqueness",
              unique: true

    remove_foreign_key :active_storage_variant_records, :active_storage_blobs
    remove_index :active_storage_variant_records, name: "index_active_storage_variant_records_uniqueness"
    add_index :active_storage_variant_records,
              %i[blob_id variation_digest],
              name: "index_active_storage_variant_records_uniqueness",
              unique: true
    add_foreign_key :active_storage_variant_records, :active_storage_blobs, column: :blob_id
  end

  private

  def mysql?
    ActiveRecord::Base.connection.adapter_name.match?(/MySQL/i)
  end
end
