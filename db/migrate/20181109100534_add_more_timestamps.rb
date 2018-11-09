class AddMoreTimestamps < ActiveRecord::Migration[5.2]
  def change
    change_table :customer_imports do |t|
      t.datetime :started_finalizing_at
      t.datetime :finalized_at
    end
  end
end
