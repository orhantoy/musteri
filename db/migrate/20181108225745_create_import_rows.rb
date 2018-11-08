class CreateImportRows < ActiveRecord::Migration[5.2]
  def change
    create_table :customer_import_rows do |t|
      t.timestamps null: false
      t.references :owner, null: false
      t.json :parsed_data
      t.boolean :with_errors, null: false, default: false
      t.boolean :duplicated, null: false, default: false
      t.string :error_message
    end
  end
end
