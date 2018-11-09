class CreateCoreTables < ActiveRecord::Migration[5.2]
  def change
    create_table :spaces do |t|
      t.timestamps null: false

      t.string :title, null: false
      t.string :slug, null: false, index: { unique: true }
    end

    create_table :customers do |t|
      t.timestamps null: false

      t.references :space, null: false
      t.string :name, null: false
      t.string :address
      t.string :city
      t.string :country_code
    end

    create_table :customer_imports do |t|
      t.timestamps null: false

      t.references :space, null: false
      t.datetime :started_parsing_at
      t.datetime :parsed_at
      t.datetime :started_finalizing_at
      t.datetime :finalized_at
    end

    create_table :customer_import_rows do |t|
      t.timestamps null: false

      t.references :owner, null: false
      t.json :parsed_data
      t.boolean :with_errors, null: false, default: false
      t.boolean :duplicated, null: false, default: false
      t.string :error_message
      t.datetime :finalized_at
    end
  end
end
