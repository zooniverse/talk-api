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

ActiveRecord::Schema.define(version: 20141203204039) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "boards", force: true do |t|
    t.string   "title",                          null: false
    t.string   "description",                    null: false
    t.string   "section"
    t.integer  "users_count",       default: 0
    t.integer  "comments_count",    default: 0
    t.integer  "discussions_count", default: 0
    t.jsonb    "permissions",       default: {}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: true do |t|
    t.string   "category"
    t.text     "body",                          null: false
    t.jsonb    "tags",          default: {}
    t.integer  "focus_id"
    t.string   "focus_type"
    t.string   "section"
    t.integer  "discussion_id"
    t.integer  "user_id",                       null: false
    t.string   "user_name",                     null: false
    t.boolean  "is_deleted",    default: false
    t.json     "versions",      default: []
    t.jsonb    "upvotes",       default: {}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conversations", force: true do |t|
    t.string   "title",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "discussions", force: true do |t|
    t.string   "title",                          null: false
    t.string   "section"
    t.integer  "board_id"
    t.integer  "user_id",                        null: false
    t.string   "user_name",                      null: false
    t.boolean  "sticky",         default: false
    t.boolean  "locked",         default: false
    t.integer  "users_count",    default: 0
    t.integer  "comments_count", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "focuses", force: true do |t|
    t.string   "type"
    t.string   "section"
    t.string   "name",                        null: false
    t.string   "description"
    t.integer  "comments_count", default: 0
    t.json     "data",           default: {}
    t.jsonb    "tags",           default: {}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", force: true do |t|
    t.integer  "conversation_id", null: false
    t.integer  "sender_id",       null: false
    t.integer  "recipient_id",    null: false
    t.string   "body",            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "moderations", force: true do |t|
    t.integer  "target_id",                null: false
    t.string   "target_type",              null: false
    t.integer  "state",       default: 0
    t.json     "reports",     default: []
    t.json     "actions",     default: []
    t.datetime "actioned_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "section"
  end

  create_table "tags", force: true do |t|
    t.string   "name",                   null: false
    t.integer  "uses",       default: 0
    t.string   "section"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_conversations", force: true do |t|
    t.integer  "user_id",                        null: false
    t.integer  "conversation_id",                null: false
    t.boolean  "is_unread",       default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name",                      null: false
    t.string   "display_name"
    t.jsonb    "roles",        default: {}
    t.json     "preferences",  default: {}
    t.json     "stats",        default: {}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
