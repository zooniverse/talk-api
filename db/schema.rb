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

ActiveRecord::Schema.define(version: 20160111193434) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgres_fdw"
  enable_extension "hstore"

  create_table "announcements", force: :cascade do |t|
    t.text     "message",    null: false
    t.string   "section",    null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

  add_index "announcements", ["created_at"], name: "index_announcements_on_created_at", using: :btree
  add_index "announcements", ["expires_at"], name: "index_announcements_on_expires_at", using: :btree
  add_index "announcements", ["section", "created_at"], name: "index_announcements_on_section_and_created_at", using: :btree

  create_table "blocked_users", force: :cascade do |t|
    t.integer  "user_id",         null: false
    t.integer  "blocked_user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blocked_users", ["user_id", "blocked_user_id"], name: "index_blocked_users_on_user_id_and_blocked_user_id", unique: true, using: :btree

  create_table "boards", force: :cascade do |t|
    t.string   "title",                                   null: false
    t.string   "description",                             null: false
    t.string   "section",                                 null: false
    t.integer  "users_count",             default: 0
    t.integer  "comments_count",          default: 0
    t.integer  "discussions_count",       default: 0
    t.json     "permissions",             default: {}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.boolean  "subject_default",         default: false, null: false
    t.integer  "project_id"
    t.datetime "last_comment_created_at"
    t.integer  "position",                default: 0
  end

  add_index "boards", ["parent_id", "position", "last_comment_created_at"], name: "sub_board_order", using: :btree
  add_index "boards", ["section", "position", "last_comment_created_at"], name: "board_order", using: :btree
  add_index "boards", ["section", "subject_default"], name: "index_boards_on_section_and_subject_default", unique: true, where: "(subject_default = true)", using: :btree

  create_table "comments", force: :cascade do |t|
    t.string   "category"
    t.text     "body",                             null: false
    t.integer  "focus_id"
    t.string   "focus_type"
    t.string   "section",                          null: false
    t.integer  "discussion_id"
    t.integer  "user_id",                          null: false
    t.string   "user_login",                       null: false
    t.boolean  "is_deleted",       default: false
    t.json     "versions",         default: []
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json     "mentioning",       default: {},    null: false
    t.json     "tagging",          default: {}
    t.hstore   "upvotes",          default: {}
    t.integer  "project_id"
    t.string   "user_ip"
    t.integer  "reply_id"
    t.integer  "board_id"
    t.json     "group_mentioning", default: {},    null: false
  end

  add_index "comments", ["board_id", "created_at"], name: "index_comments_on_board_id_and_created_at", using: :btree
  add_index "comments", ["board_id"], name: "index_comments_on_board_id", using: :btree
  add_index "comments", ["created_at"], name: "index_comments_on_created_at", using: :btree
  add_index "comments", ["discussion_id", "created_at"], name: "index_comments_on_discussion_id_and_created_at", using: :btree
  add_index "comments", ["discussion_id"], name: "index_comments_on_discussion_id", using: :btree
  add_index "comments", ["focus_id", "focus_type"], name: "index_comments_on_focus_id_and_focus_type", using: :btree
  add_index "comments", ["section", "board_id", "created_at"], name: "index_comments_on_section_and_board_id_and_created_at", using: :btree
  add_index "comments", ["section", "created_at"], name: "index_comments_on_section_and_created_at", using: :btree
  add_index "comments", ["user_id", "created_at"], name: "index_comments_on_user_id_and_created_at", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "conversations", force: :cascade do |t|
    t.string   "title",                        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "participant_ids", default: [],              array: true
  end

  create_table "data_requests", force: :cascade do |t|
    t.integer  "user_id",                null: false
    t.string   "section",                null: false
    t.string   "kind",                   null: false
    t.datetime "expires_at",             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "state",      default: 0, null: false
    t.integer  "project_id"
    t.string   "url"
  end

  add_index "data_requests", ["expires_at"], name: "index_data_requests_on_expires_at", using: :btree
  add_index "data_requests", ["section", "kind", "user_id"], name: "index_data_requests_on_section_and_kind_and_user_id", unique: true, using: :btree

  create_table "discussions", force: :cascade do |t|
    t.string   "title",                                   null: false
    t.string   "section",                                 null: false
    t.integer  "board_id"
    t.integer  "user_id",                                 null: false
    t.string   "user_login",                              null: false
    t.boolean  "sticky",                  default: false
    t.boolean  "locked",                  default: false
    t.integer  "users_count",             default: 0
    t.integer  "comments_count",          default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "sticky_position"
    t.boolean  "subject_default",         default: false, null: false
    t.integer  "project_id"
    t.integer  "focus_id"
    t.string   "focus_type"
    t.datetime "last_comment_created_at"
  end

  add_index "discussions", ["board_id", "last_comment_created_at"], name: "index_discussions_on_board_id_and_last_comment_created_at", using: :btree
  add_index "discussions", ["board_id", "sticky", "sticky_position"], name: "index_discussions_on_board_id_and_sticky_and_sticky_position", where: "(sticky = true)", using: :btree
  add_index "discussions", ["board_id", "title", "subject_default"], name: "index_discussions_on_board_id_and_title_and_subject_default", unique: true, where: "(subject_default = true)", using: :btree

  create_table "event_logs", force: :cascade do |t|
    t.integer  "user_id"
    t.json     "payload"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "label"
  end

  create_table "group_mentions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "comment_id"
    t.string   "section"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_mentions", ["comment_id", "name"], name: "index_group_mentions_on_comment_id_and_name", using: :btree
  add_index "group_mentions", ["comment_id"], name: "index_group_mentions_on_comment_id", using: :btree

  create_table "mentions", force: :cascade do |t|
    t.integer  "mentionable_id",   null: false
    t.string   "mentionable_type", null: false
    t.integer  "comment_id",       null: false
    t.integer  "user_id",          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "section"
    t.integer  "project_id"
    t.integer  "board_id"
  end

  add_index "mentions", ["board_id"], name: "index_mentions_on_board_id", using: :btree
  add_index "mentions", ["comment_id"], name: "index_mentions_on_comment_id", using: :btree
  add_index "mentions", ["mentionable_id", "mentionable_type", "created_at"], name: "mentionable_created_at", using: :btree
  add_index "mentions", ["mentionable_id", "mentionable_type", "section", "created_at"], name: "mentionable_section_created_at", using: :btree
  add_index "mentions", ["mentionable_id", "mentionable_type"], name: "index_mentions_on_mentionable_id_and_mentionable_type", using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "conversation_id", null: false
    t.string   "body",            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",         null: false
    t.string   "user_ip"
  end

  add_index "messages", ["conversation_id", "created_at"], name: "index_messages_on_conversation_id_and_created_at", using: :btree

  create_table "moderations", force: :cascade do |t|
    t.integer  "target_id"
    t.string   "target_type"
    t.integer  "state",            default: 0
    t.json     "reports",          default: []
    t.json     "actions",          default: []
    t.datetime "actioned_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "section",                       null: false
    t.json     "destroyed_target"
    t.integer  "project_id"
  end

  add_index "moderations", ["section", "state", "updated_at"], name: "index_moderations_on_section_and_state_and_updated_at", using: :btree
  add_index "moderations", ["target_id", "target_type"], name: "index_moderations_on_target_id_and_target_type", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "message",                         null: false
    t.string   "url",                             null: false
    t.string   "section",                         null: false
    t.boolean  "delivered",       default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "subscription_id",                 null: false
    t.integer  "project_id"
    t.integer  "source_id"
    t.string   "source_type"
  end

  add_index "notifications", ["created_at"], name: "expiring_index", using: :btree
  add_index "notifications", ["source_id", "source_type"], name: "index_notifications_on_source_id_and_source_type", using: :btree
  add_index "notifications", ["subscription_id"], name: "index_notifications_on_subscription_id", using: :btree
  add_index "notifications", ["user_id", "created_at"], name: "index_notifications_on_user_id_and_created_at", using: :btree
  add_index "notifications", ["user_id", "delivered", "created_at"], name: "unread_index", using: :btree
  add_index "notifications", ["user_id", "section", "created_at"], name: "index_notifications_on_user_id_and_section_and_created_at", using: :btree
  add_index "notifications", ["user_id", "section", "delivered", "created_at"], name: "unread_section_index", using: :btree

  create_table "roles", force: :cascade do |t|
    t.integer  "user_id",                   null: false
    t.string   "section",                   null: false
    t.string   "name",                      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_shown",   default: true, null: false
  end

  add_index "roles", ["user_id", "section", "is_shown"], name: "index_roles_on_user_id_and_section_and_is_shown", using: :btree
  add_index "roles", ["user_id", "section", "name"], name: "index_roles_on_user_id_and_section_and_name", unique: true, using: :btree

  create_table "searchable_boards", primary_key: "searchable_id", force: :cascade do |t|
    t.string   "searchable_type",              null: false
    t.tsvector "content",         default: "", null: false
    t.string   "sections",        default: [], null: false, array: true
  end

  add_index "searchable_boards", ["content"], name: "index_searchable_boards_on_content", using: :gin
  add_index "searchable_boards", ["searchable_type"], name: "index_searchable_boards_on_searchable_type", using: :btree
  add_index "searchable_boards", ["sections"], name: "index_searchable_boards_on_sections", using: :gin

  create_table "searchable_comments", primary_key: "searchable_id", force: :cascade do |t|
    t.string   "searchable_type",              null: false
    t.tsvector "content",         default: "", null: false
    t.string   "sections",        default: [], null: false, array: true
  end

  add_index "searchable_comments", ["content"], name: "index_searchable_comments_on_content", using: :gin
  add_index "searchable_comments", ["searchable_type"], name: "index_searchable_comments_on_searchable_type", using: :btree
  add_index "searchable_comments", ["sections"], name: "index_searchable_comments_on_sections", using: :gin

  create_table "searchable_discussions", primary_key: "searchable_id", force: :cascade do |t|
    t.string   "searchable_type",              null: false
    t.tsvector "content",         default: "", null: false
    t.string   "sections",        default: [], null: false, array: true
  end

  add_index "searchable_discussions", ["content"], name: "index_searchable_discussions_on_content", using: :gin
  add_index "searchable_discussions", ["searchable_type"], name: "index_searchable_discussions_on_searchable_type", using: :btree
  add_index "searchable_discussions", ["sections"], name: "index_searchable_discussions_on_sections", using: :gin

  create_table "subscription_preferences", force: :cascade do |t|
    t.integer  "category",                    null: false
    t.integer  "user_id",                     null: false
    t.integer  "email_digest", default: 0,    null: false
    t.boolean  "enabled",      default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subscription_preferences", ["user_id", "category"], name: "index_subscription_preferences_on_user_id_and_category", using: :btree

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "category",                   null: false
    t.integer  "user_id",                    null: false
    t.integer  "source_id",                  null: false
    t.string   "source_type",                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "enabled",     default: true, null: false
  end

  add_index "subscriptions", ["source_id", "source_type"], name: "index_subscriptions_on_source_id_and_source_type", using: :btree
  add_index "subscriptions", ["user_id", "category"], name: "index_subscriptions_on_user_id_and_category", using: :btree
  add_index "subscriptions", ["user_id", "source_id", "source_type", "category"], name: "index_subscriptions_uniquely", unique: true, using: :btree
  add_index "subscriptions", ["user_id", "source_id", "source_type"], name: "index_subscriptions_on_user_id_and_source_id_and_source_type", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name",          null: false
    t.string   "section",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",       null: false
    t.integer  "comment_id",    null: false
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "project_id"
    t.string   "user_login"
  end

  add_index "tags", ["comment_id"], name: "index_tags_on_comment_id", using: :btree
  add_index "tags", ["section", "taggable_type", "name"], name: "index_tags_on_section_and_taggable_type_and_name", using: :btree
  add_index "tags", ["section", "taggable_type"], name: "index_tags_on_section_and_taggable_type", using: :btree
  add_index "tags", ["taggable_id", "taggable_type"], name: "index_tags_on_taggable_id_and_taggable_type", using: :btree

  create_table "unsubscribe_tokens", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.string   "token",      null: false
    t.datetime "expires_at", null: false
  end

  add_index "unsubscribe_tokens", ["expires_at"], name: "index_unsubscribe_tokens_on_expires_at", using: :btree
  add_index "unsubscribe_tokens", ["token"], name: "index_unsubscribe_tokens_on_token", unique: true, using: :btree
  add_index "unsubscribe_tokens", ["user_id"], name: "index_unsubscribe_tokens_on_user_id", unique: true, using: :btree

  create_table "user_conversations", force: :cascade do |t|
    t.integer  "user_id",                        null: false
    t.integer  "conversation_id",                null: false
    t.boolean  "is_unread",       default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_conversations", ["conversation_id", "user_id", "is_unread"], name: "unread_user_conversations", using: :btree
  add_index "user_conversations", ["conversation_id", "user_id"], name: "index_user_conversations_on_conversation_id_and_user_id", using: :btree

  create_table "user_ip_bans", force: :cascade do |t|
    t.cidr     "ip",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_ip_bans", ["ip"], name: "index_user_ip_bans_on_ip", using: :btree

end
