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

ActiveRecord::Schema.define(version: 20150728185218) do

  create_table "accounts", force: true do |t|
    t.string "phone_number"
    t.string "auth_token"
    t.string "name"
    t.string "reset_code"
    t.string "start_code"
  end

  create_table "contacts", force: true do |t|
    t.string   "phone_number"
    t.string   "name"
    t.boolean  "opted_in"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "bot_complete"
    t.string   "language"
    t.integer  "account_id"
  end

  add_index "contacts", ["account_id"], name: "index_contacts_on_account_id"

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "languages", force: true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "matches", force: true do |t|
    t.datetime "time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "home_team_id"
    t.integer  "away_team_id"
    t.integer  "round_id"
  end

  add_index "matches", ["away_team_id"], name: "index_matches_on_away_team_id"
  add_index "matches", ["home_team_id"], name: "index_matches_on_home_team_id"
  add_index "matches", ["round_id"], name: "index_matches_on_round_id"

  create_table "media", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "remote_asset_id"
  end

  create_table "menus", force: true do |t|
    t.integer  "step_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "action"
  end

  create_table "messages", force: true do |t|
    t.string   "text"
    t.string   "message_type"
    t.integer  "external_id"
    t.boolean  "sent"
    t.boolean  "received"
    t.string   "phone_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "account_id"
  end

  add_index "messages", ["account_id"], name: "index_messages_on_account_id"

  create_table "options", force: true do |t|
    t.integer  "index"
    t.string   "text"
    t.string   "key"
    t.integer  "step_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "menu_id"
    t.integer  "question_id"
    t.string   "option_type", default: "key"
  end

  add_index "options", ["menu_id"], name: "index_options_on_menu_id"
  add_index "options", ["question_id"], name: "index_options_on_question_id"

  create_table "players", force: true do |t|
    t.string   "phone_number"
    t.string   "name"
    t.integer  "team_id"
    t.boolean  "subscribed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "players", ["team_id"], name: "index_players_on_team_id"

  create_table "predictions", force: true do |t|
    t.integer  "player_id"
    t.integer  "match_id"
    t.integer  "home_score"
    t.integer  "away_score"
    t.boolean  "confirmed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "predictions", ["match_id"], name: "index_predictions_on_match_id"
  add_index "predictions", ["player_id"], name: "index_predictions_on_player_id"

  create_table "progresses", force: true do |t|
    t.integer  "contact_id"
    t.integer  "step_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "player_id"
  end

  add_index "progresses", ["contact_id"], name: "index_progresses_on_contact_id"
  add_index "progresses", ["player_id"], name: "index_progresses_on_player_id"
  add_index "progresses", ["step_id"], name: "index_progresses_on_step_id"

  create_table "questions", force: true do |t|
    t.text     "text"
    t.integer  "step_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "remote_asset_id"
    t.integer  "media_id"
    t.string   "language",           default: "en"
    t.integer  "account_id"
  end

  add_index "questions", ["account_id"], name: "index_questions_on_account_id"
  add_index "questions", ["media_id"], name: "index_questions_on_media_id"
  add_index "questions", ["step_id"], name: "index_questions_on_step_id"

  create_table "response_actions", force: true do |t|
    t.string   "name"
    t.string   "parameters"
    t.string   "action_type"
    t.string   "response_type"
    t.integer  "step_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "delay_by"
  end

  add_index "response_actions", ["step_id"], name: "index_response_actions_on_step_id"

  create_table "responses", force: true do |t|
    t.string   "text"
    t.integer  "progress_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "response_type"
    t.integer  "account_id"
  end

  add_index "responses", ["account_id"], name: "index_responses_on_account_id"
  add_index "responses", ["progress_id"], name: "index_responses_on_progress_id"

  create_table "results", force: true do |t|
    t.integer  "match_id"
    t.integer  "home_score"
    t.integer  "away_score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "results", ["match_id"], name: "index_results_on_match_id"

  create_table "rounds", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  create_table "steps", force: true do |t|
    t.string   "name"
    t.string   "step_type"
    t.integer  "order_index"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "next_step_id"
    t.text     "expected_answer", limit: 255
    t.boolean  "allow_continue"
    t.text     "wrong_answer"
    t.text     "rebound"
    t.string   "action"
    t.integer  "account_id"
    t.integer  "wizard_id"
  end

  add_index "steps", ["account_id"], name: "index_steps_on_account_id"
  add_index "steps", ["next_step_id"], name: "index_steps_on_next_step_id"
  add_index "steps", ["wizard_id"], name: "index_steps_on_wizard_id"

  create_table "system_responses", force: true do |t|
    t.text     "text",               limit: 255
    t.string   "response_type"
    t.integer  "step_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "value"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "remote_asset_id"
    t.integer  "media_id"
    t.string   "language",                       default: "en"
    t.integer  "account_id"
  end

  add_index "system_responses", ["account_id"], name: "index_system_responses_on_account_id"
  add_index "system_responses", ["media_id"], name: "index_system_responses_on_media_id"
  add_index "system_responses", ["step_id"], name: "index_system_responses_on_step_id"

  create_table "teams", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "wizards", force: true do |t|
    t.string   "start_keyword"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "reset_keyword"
    t.integer  "restart_in"
    t.text     "welcome_text"
  end

  add_index "wizards", ["account_id"], name: "index_wizards_on_account_id"

end
