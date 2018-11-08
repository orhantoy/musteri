class CreateCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :customers do |t|
      t.timestamps null: false
      t.references :space, null: false
      t.string :name, null: false
      t.string :address
      t.string :city
      t.string :country_code
    end
  end
end
