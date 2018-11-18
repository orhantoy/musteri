class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.timestamps null: false
      t.string :email, null: false, index: { unique: true }
      t.string :name
      t.string :password_digest
    end

    create_table :customer_memberships do |t|
      t.datetime :created_at, null: false
      t.references :user, null: false
      t.references :customer, null: false
      t.string :confirmation_token
      t.datetime :confirmed_at
    end
  end
end
