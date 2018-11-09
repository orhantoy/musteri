# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_11_08_220931) do

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
    t.json "parsed_data"
    t.boolean "with_errors", default: false, null: false
    t.boolean "duplicated", default: false, null: false
    t.string "error_message"
    t.datetime "finalized_at"
    t.index ["owner_id"], name: "index_customer_import_rows_on_owner_id"
  end

  create_table "customer_imports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "space_id", null: false
    t.datetime "started_parsing_at"
    t.datetime "parsed_at"
    t.datetime "started_finalizing_at"
    t.datetime "finalized_at"
    t.index ["space_id"], name: "index_customer_imports_on_space_id"
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

end
