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

ActiveRecord::Schema.define(version: 20141118123258) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "boards", force: true do |t|
    t.string   "title",                                                       null: false
    t.string   "description",                                                 null: false
    t.string   "section"
    t.json     "last_comment"
    t.integer  "users_count",       default: 0
    t.integer  "comments_count",    default: 0
    t.integer  "discussions_count", default: 0
    t.json     "permissions",       default: {"read"=>"all", "write"=>"all"}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: true do |t|
    t.string   "category"
    t.text     "body",                              null: false
    t.json     "tags",              default: {}
    t.integer  "focus_id"
    t.string   "focus_type"
    t.string   "section"
    t.integer  "discussion_id"
    t.string   "discussion_title"
    t.integer  "board_id"
    t.string   "board_title"
    t.integer  "user_id",                           null: false
    t.string   "user_name",                         null: false
    t.string   "user_display_name"
    t.boolean  "is_deleted",        default: false
    t.json     "versions",          default: []
    t.json     "upvotes",           default: {}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conversations", force: true do |t|
    t.string   "title",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "discussions", force: true do |t|
    t.string   "title",                             null: false
    t.integer  "first_comment_id"
    t.string   "section"
    t.integer  "board_id"
    t.string   "board_title"
    t.integer  "user_id",                           null: false
    t.string   "user_name",                         null: false
    t.string   "user_display_name"
    t.boolean  "sticky",            default: false
    t.boolean  "locked",            default: false
    t.json     "last_comment"
    t.integer  "users_count",       default: 0
    t.integer  "comments_count",    default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "focuses", id: false, force: true do |t|
    t.integer  "id",                          null: false
    t.string   "type",                        null: false
    t.string   "section"
    t.string   "name",                        null: false
    t.string   "description"
    t.integer  "comments_count", default: 0
    t.json     "data",           default: {}
    t.json     "tags",           default: {}
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
    t.json     "action"
    t.datetime "actioned_at"
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

  create_table "users", id: false, force: true do |t|
    t.integer  "id",                        null: false
    t.string   "name",                      null: false
    t.string   "display_name"
    t.json     "roles",        default: {}
    t.json     "preferences",  default: {}
    t.json     "stats",        default: {}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
