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

ActiveRecord::Schema.define(version: 20150226200251) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "postgres_fdw"

  create_table "boards", force: :cascade do |t|
    t.string   "title",                          null: false
    t.string   "description",                    null: false
    t.string   "section",                        null: false
    t.integer  "users_count",       default: 0
    t.integer  "comments_count",    default: 0
    t.integer  "discussions_count", default: 0
    t.json     "permissions",       default: {}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
  end

  add_index "boards", ["parent_id", "created_at"], name: "index_boards_on_parent_id_and_created_at", using: :btree
  add_index "boards", ["section", "created_at"], name: "index_boards_on_section_and_created_at", using: :btree

  create_table "comments", force: :cascade do |t|
    t.string   "category"
    t.text     "body",                          null: false
    t.integer  "focus_id"
    t.string   "focus_type"
    t.string   "section",                       null: false
    t.integer  "discussion_id"
    t.integer  "user_id",                       null: false
    t.string   "user_login",                    null: false
    t.boolean  "is_deleted",    default: false
    t.json     "versions",      default: []
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json     "mentioning",    default: {},    null: false
    t.json     "tagging",       default: {}
    t.hstore   "upvotes",       default: {}
  end

  add_index "comments", ["created_at"], name: "index_comments_on_created_at", using: :btree
  add_index "comments", ["discussion_id"], name: "index_comments_on_discussion_id", using: :btree
  add_index "comments", ["focus_id", "focus_type"], name: "index_comments_on_focus_id_and_focus_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "conversations", force: :cascade do |t|
    t.string   "title",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "conversations", ["updated_at"], name: "index_conversations_on_updated_at", using: :btree

  create_table "discussions", force: :cascade do |t|
    t.string   "title",                           null: false
    t.string   "section",                         null: false
    t.integer  "board_id"
    t.integer  "user_id",                         null: false
    t.string   "user_login",                      null: false
    t.boolean  "sticky",          default: false
    t.boolean  "locked",          default: false
    t.integer  "users_count",     default: 0
    t.integer  "comments_count",  default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sticky_position"
  end

  add_index "discussions", ["board_id", "sticky", "sticky_position"], name: "index_discussions_on_board_id_and_sticky_and_sticky_position", using: :btree
  add_index "discussions", ["board_id", "sticky", "updated_at"], name: "index_discussions_on_board_id_and_sticky_and_updated_at", using: :btree
  add_index "discussions", ["board_id", "updated_at"], name: "index_discussions_on_board_id_and_updated_at", using: :btree

  create_table "mentions", force: :cascade do |t|
    t.integer  "mentionable_id",   null: false
    t.string   "mentionable_type", null: false
    t.integer  "comment_id",       null: false
    t.integer  "user_id",          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mentions", ["comment_id"], name: "index_mentions_on_comment_id", using: :btree
  add_index "mentions", ["mentionable_id"], name: "index_mentions_on_mentionable_id", using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "conversation_id", null: false
    t.string   "body",            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",         null: false
  end

  add_index "messages", ["conversation_id", "created_at"], name: "index_messages_on_conversation_id_and_created_at", using: :btree

  create_table "moderations", force: :cascade do |t|
    t.integer  "target_id",                null: false
    t.string   "target_type",              null: false
    t.integer  "state",       default: 0
    t.json     "reports",     default: []
    t.json     "actions",     default: []
    t.datetime "actioned_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "section",                  null: false
  end

  add_index "moderations", ["section", "state", "updated_at"], name: "index_moderations_on_section_and_state_and_updated_at", using: :btree
  add_index "moderations", ["target_id", "target_type"], name: "index_moderations_on_target_id_and_target_type", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name",          null: false
    t.string   "section",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",       null: false
    t.integer  "comment_id",    null: false
    t.integer  "taggable_id"
    t.string   "taggable_type"
  end

  add_index "tags", ["section", "taggable_type", "name"], name: "index_tags_on_section_and_taggable_type_and_name", using: :btree
  add_index "tags", ["section", "taggable_type"], name: "index_tags_on_section_and_taggable_type", using: :btree
  add_index "tags", ["taggable_id", "taggable_type"], name: "index_tags_on_taggable_id_and_taggable_type", using: :btree

  create_table "user_conversations", force: :cascade do |t|
    t.integer  "user_id",                        null: false
    t.integer  "conversation_id",                null: false
    t.boolean  "is_unread",       default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_conversations", ["conversation_id", "user_id", "is_unread"], name: "unread_user_conversations", using: :btree
  add_index "user_conversations", ["conversation_id", "user_id"], name: "index_user_conversations_on_conversation_id_and_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "login",                     null: false
    t.string   "display_name"
    t.json     "roles",        default: {}
    t.json     "preferences",  default: {}
    t.json     "stats",        default: {}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                     null: false
  end

  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree

end
