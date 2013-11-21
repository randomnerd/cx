class AddFailedAttemptsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :failed_attempts, :integer
  end
end
