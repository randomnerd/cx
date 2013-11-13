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

ActiveRecord::Schema.define(version: 20131113191805) do

  create_table "balance_changes", force: true do |t|
    t.integer  "amount",       limit: 8, default: 0
    t.integer  "held",         limit: 8, default: 0
    t.integer  "balance_id"
    t.integer  "subject_id"
    t.string   "subject_type"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "balance_changes", ["balance_id"], name: "index_balance_changes_on_balance_id", using: :btree
  add_index "balance_changes", ["subject_id", "subject_type"], name: "index_balance_changes_on_subject_id_and_subject_type", using: :btree

  create_table "balances", force: true do |t|
    t.integer  "currency_id"
    t.integer  "user_id"
    t.integer  "amount",      limit: 8, default: 0
    t.integer  "held",        limit: 8, default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "balances", ["amount"], name: "index_balances_on_amount", using: :btree
  add_index "balances", ["user_id", "currency_id"], name: "index_balances_on_user_id_and_currency_id", using: :btree

  create_table "chart_items", force: true do |t|
    t.datetime "time"
    t.integer  "o",             limit: 8, default: 0
    t.integer  "h",             limit: 8, default: 0
    t.integer  "l",             limit: 8, default: 0
    t.integer  "c",             limit: 8, default: 0
    t.integer  "v",             limit: 8, default: 0
    t.integer  "trade_pair_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "chart_items", ["trade_pair_id", "time"], name: "index_chart_items_on_trade_pair_id_and_time", using: :btree

  create_table "currencies", force: true do |t|
    t.string   "name"
    t.text     "desc"
    t.integer  "blk_conf"
    t.integer  "tx_conf"
    t.float    "diff"
    t.float    "hashrate"
    t.float    "net_hashrate"
    t.float    "tx_fee"
    t.boolean  "mining_enabled"
    t.boolean  "mining_public"
    t.string   "mining_url"
    t.boolean  "public"
    t.float    "mining_fee"
    t.time     "last_block_at"
    t.string   "user"
    t.string   "pass"
    t.string   "host"
    t.integer  "port"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "currencies", ["name", "public"], name: "index_currencies_on_name_and_public", using: :btree

  create_table "incomes", force: true do |t|
    t.integer  "amount",       limit: 8
    t.integer  "currency_id"
    t.integer  "subject_id"
    t.string   "subject_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "incomes", ["currency_id"], name: "index_incomes_on_currency_id", using: :btree
  add_index "incomes", ["subject_id", "subject_type"], name: "index_incomes_on_subject_id_and_subject_type", using: :btree

  create_table "messages", force: true do |t|
    t.text     "body"
    t.integer  "user_id"
    t.boolean  "system"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", force: true do |t|
    t.text     "body"
    t.string   "title"
    t.boolean  "ack"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notifications", ["user_id", "ack"], name: "index_notifications_on_user_id_and_ack", using: :btree

  create_table "orders", force: true do |t|
    t.integer  "amount",        limit: 8
    t.integer  "rate",          limit: 8
    t.boolean  "bid"
    t.boolean  "cancelled",               default: false
    t.boolean  "complete",                default: false
    t.float    "fee",                     default: 0.0
    t.integer  "filled",        limit: 8, default: 0
    t.integer  "trade_pair_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orders", ["user_id", "trade_pair_id", "rate", "complete", "cancelled", "bid"], name: "orders_index", using: :btree

  create_table "trade_pairs", force: true do |t|
    t.float    "buy_fee"
    t.float    "sell_fee"
    t.integer  "last_price",      limit: 8
    t.integer  "market_id"
    t.integer  "currency_id"
    t.boolean  "public"
    t.string   "url_slug"
    t.integer  "currency_volume", limit: 8
    t.integer  "market_volume",   limit: 8
    t.integer  "rate_min",        limit: 8
    t.integer  "rate_max",        limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "trade_pairs", ["currency_id"], name: "index_trade_pairs_on_currency_id", using: :btree
  add_index "trade_pairs", ["market_id"], name: "index_trade_pairs_on_market_id", using: :btree
  add_index "trade_pairs", ["public"], name: "index_trade_pairs_on_public", using: :btree
  add_index "trade_pairs", ["url_slug"], name: "index_trade_pairs_on_url_slug", using: :btree

  create_table "trades", force: true do |t|
    t.boolean  "bid"
    t.integer  "rate",          limit: 8
    t.integer  "amount",        limit: 8
    t.integer  "ask_id"
    t.integer  "ask_user_id"
    t.integer  "bid_id"
    t.integer  "bid_user_id"
    t.integer  "trade_pair_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "trades", ["ask_id"], name: "index_trades_on_ask_id", using: :btree
  add_index "trades", ["ask_user_id"], name: "index_trades_on_ask_user_id", using: :btree
  add_index "trades", ["bid_id"], name: "index_trades_on_bid_id", using: :btree
  add_index "trades", ["bid_user_id"], name: "index_trades_on_bid_user_id", using: :btree
  add_index "trades", ["trade_pair_id"], name: "index_trades_on_trade_pair_id", using: :btree

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
    t.string   "nickname"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["nickname"], name: "index_users_on_nickname", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
