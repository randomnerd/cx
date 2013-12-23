class FixIndexes < ActiveRecord::Migration
  def change
    remove_index "address_book_items", ["user_id", "currency_id"]
    add_index :address_book_items, :user_id
    add_index :address_book_items, :currency_id
    remove_index "balance_changes", ["subject_id", "subject_type"]
    add_index :balance_changes, :subject_id
    add_index :balance_changes, :subject_type
    remove_index "balances", ["user_id", "currency_id"]
    add_index :balances, :user_id
    add_index :balances, :currency_id
    remove_index "block_payouts", ["block_id", "user_id"]
    add_index :block_payouts, :block_id
    add_index :block_payouts, :user_id
    remove_index "blocks", ["currency_id", "paid", "category"]
    add_index :blocks, :currency_id
    add_index :blocks, :paid
    add_index :blocks, :category
    remove_index "blocks", ["user_id", "currency_id"]
    add_index :blocks, :user_id
    remove_index "chart_items", ["trade_pair_id", "time"]
    add_index :chart_items, :trade_pair_id
    add_index :chart_items, :time
    remove_index "currencies", ["name", "public"]
    add_index :currencies, :name
    add_index :currencies, :public
    remove_index "deposits", ["processed", "confirmations"]
    add_index :deposits, :processed
    add_index :deposits, :confirmations
    remove_index "deposits", ["user_id", "wallet_id", "currency_id"]
    add_index :deposits, :user_id
    add_index :deposits, :wallet_id
    add_index :deposits, :currency_id
    remove_index "hashrates", ["user_id", "currency_id"]
    add_index :hashrates, :user_id
    add_index :hashrates, :currency_id
    remove_index "incomes", ["subject_id", "subject_type"]
    add_index :incomes, :subject_id
    add_index :incomes, :subject_type
    remove_index "notifications", ["user_id", "ack"]
    add_index :notifications, :user_id
    add_index :notifications, :ack
    remove_index "orders", name: "orders_index"
    add_index :orders, :user_id
    add_index :orders, :trade_pair_id
    add_index :orders, :rate
    add_index :orders, :complete
    add_index :orders, :cancelled
    add_index :orders, :bid
    add_index :trades, :created_at
    remove_index "wallets", ["user_id", "currency_id"]
    add_index :wallets, :user_id
    add_index :wallets, :currency_id
    remove_index "withdrawals", ["user_id", "currency_id"]
    add_index :withdrawals, :user_id
    add_index :withdrawals, :currency_id
    remove_index "worker_stats", ["worker_id", "currency_id", "updated_at"]
    add_index :worker_stats, :worker_id
    add_index :worker_stats, :currency_id
    add_index :worker_stats, :updated_at
    remove_index "workers", ["name", "pass"]
    add_index :workers, :name
    add_index :workers, :pass
  end
end
