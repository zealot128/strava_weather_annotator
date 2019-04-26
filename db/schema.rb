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

ActiveRecord::Schema.define(version: 2019_04_26_200707) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_jieba"
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

  create_table "api_logs", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "title"
    t.string "provider"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "date", "provider"], name: "index_api_logs_on_user_id_and_date_and_provider"
  end

  create_table "trip_streams", force: :cascade do |t|
    t.bigint "trip_id"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trip_id"], name: "index_trip_streams_on_trip_id"
  end

  create_table "trips", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.string "date"
    t.text "description"
    t.string "link"
    t.string "strava_id"
    t.float "distance"
    t.string "activity_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "polyline"
    t.datetime "start_datetime"
    t.string "temperature"
    t.string "icon"
    t.boolean "commented_posted"
    t.index ["user_id"], name: "index_trips_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "provider"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "access_token"
    t.string "profile_picture_url"
  end

  create_table "weather_informations", id: :serial, force: :cascade do |t|
    t.integer "trip_id"
    t.integer "offset"
    t.datetime "datetime"
    t.json "data"
    t.float "lat"
    t.float "lon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trip_id"], name: "index_weather_informations_on_trip_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "trip_streams", "trips"
  add_foreign_key "trips", "users"
  add_foreign_key "weather_informations", "trips"
end
