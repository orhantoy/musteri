class SchemaChangesForDynamicColumnHandling < ActiveRecord::Migration[5.2]
  def change
    change_table :customer_imports do |t|
      t.datetime :started_parsing_header_at
      t.datetime :parsed_header_at
      t.json :header_data
    end

    change_table :customer_import_rows do |t|
      t.json :cell_data
    end
  end
end
