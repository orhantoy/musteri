class DeleteParsedData < ActiveRecord::Migration[5.2]
  def change
    remove_column :customer_import_rows, :parsed_data
  end
end
