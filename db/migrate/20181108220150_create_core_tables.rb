class CreateCoreTables < ActiveRecord::Migration[5.2]
  def change
    create_table :spaces do |t|
      t.timestamps null: false
      t.string :slug, null: false, index: { unique: true }
    end

    create_table :customer_imports do |t|
      t.timestamps null: false
      t.references :space, null: false
    end
  end
end
