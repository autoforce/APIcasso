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

ActiveRecord::Schema.define(version: 2018_09_20_133933) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

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

  create_table "apicasso_keys", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.json "scope"
    t.integer "scope_type"
    t.json "request_limiting"
    t.text "token"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "apicasso_requests", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.text "api_key_id"
    t.json "object"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "used_models", force: :cascade do |t|
    t.boolean "active", default: true
    t.integer "account_id", null: false
    t.integer "unit_id", null: false
    t.string "brand"
    t.string "name"
    t.string "slug", null: false
    t.string "model"
    t.string "version"
    t.integer "model_year"
    t.string "production_year"
    t.string "kind"
    t.boolean "new_vehicle", default: false
    t.string "old_price"
    t.integer "price_value"
    t.string "price"
    t.string "category"
    t.string "transmission"
    t.integer "km_value"
    t.string "km"
    t.string "plate"
    t.string "color"
    t.integer "doors"
    t.integer "fuel"
    t.string "fuel_text"
    t.text "note"
    t.string "chassis"
    t.boolean "shielded", default: false
    t.boolean "featured", default: false
    t.string "integrator"
    t.integer "ordination", default: 0
    t.integer "visits", default: 0
    t.integer "bait_id", default: 6
    t.integer "fipe_id"
    t.string "identifier"
    t.string "synced_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
