# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_03_03_115437) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "customer_import_rows", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "owner_id", null: false
    t.boolean "with_errors", default: false, null: false
    t.boolean "duplicated", default: false, null: false
    t.string "error_message"
    t.datetime "finalized_at"
    t.json "cell_data"
    t.index ["owner_id"], name: "index_customer_import_rows_on_owner_id"
  end

  create_table "customer_imports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "space_id", null: false
    t.datetime "started_parsing_at"
    t.datetime "parsed_at"
    t.datetime "parsing_failed_at"
    t.string "parsing_failure_message"
    t.datetime "started_finalizing_at"
    t.datetime "finalized_at"
    t.datetime "started_parsing_header_at"
    t.datetime "parsed_header_at"
    t.json "header_data"
    t.index ["space_id"], name: "index_customer_imports_on_space_id"
  end

  create_table "customer_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "user_id", null: false
    t.bigint "customer_id", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.index ["customer_id"], name: "index_customer_memberships_on_customer_id"
    t.index ["user_id"], name: "index_customer_memberships_on_user_id"
  end

  create_table "customers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "space_id", null: false
    t.string "name", null: false
    t.string "address"
    t.string "city"
    t.string "country_code"
    t.index ["space_id"], name: "index_customers_on_space_id"
  end

  create_table "spaces", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title", null: false
    t.string "slug", null: false
    t.index ["slug"], name: "index_spaces_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", null: false
    t.string "name"
    t.string "password_digest"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
end
