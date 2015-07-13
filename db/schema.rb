# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150712194514) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "trips", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "date"
    t.text     "description"
    t.string   "link"
    t.string   "strava_id"
    t.float    "distance"
    t.string   "activity_type"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.text     "polyline"
    t.datetime "start_datetime"
  end

  add_index "trips", ["user_id"], name: "index_trips_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "access_token"
    t.string   "profile_picture_url"
  end

  create_table "weather_informations", force: :cascade do |t|
    t.integer  "trip_id"
    t.integer  "offset"
    t.datetime "datetime"
    t.json     "data"
    t.float    "lat"
    t.float    "lon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "weather_informations", ["trip_id"], name: "index_weather_informations_on_trip_id", using: :btree

  add_foreign_key "trips", "users"
  add_foreign_key "weather_informations", "trips"
end
