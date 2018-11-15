class AddFailureTimestamps < ActiveRecord::Migration[5.2]
  def change
    change_table :customer_imports do |t|
      t.datetime :parsing_failed_at
      t.string :parsing_failure_message
    end
  end
end
