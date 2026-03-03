# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_03_154622) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "chats", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "users_id", null: false
    t.index ["users_id"], name: "index_chats_on_users_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "chats_id", null: false
    t.string "content"
    t.datetime "created_at", null: false
    t.string "role"
    t.datetime "updated_at", null: false
    t.index ["chats_id"], name: "index_messages_on_chats_id"
  end

  create_table "recipes", force: :cascade do |t|
    t.text "comment"
    t.datetime "created_at", null: false
    t.string "ingredient"
    t.text "mode_operatoire"
    t.text "preparation"
    t.integer "rating"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "user_recipes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "recipes_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "users_id", null: false
    t.index ["recipes_id"], name: "index_user_recipes_on_recipes_id"
    t.index ["users_id"], name: "index_user_recipes_on_users_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "chats", "users", column: "users_id"
  add_foreign_key "messages", "chats", column: "chats_id"
  add_foreign_key "user_recipes", "recipes", column: "recipes_id"
  add_foreign_key "user_recipes", "users", column: "users_id"
end
