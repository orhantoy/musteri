class AddSomeTimestamps < ActiveRecord::Migration[5.2]
  def change
    change_table :customer_imports do |t|
      t.datetime :parsed_at
    end
  end
end
