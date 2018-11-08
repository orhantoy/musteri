class CustomerImport < ApplicationRecord
  belongs_to :space

  has_one_attached :uploaded_file

  validates :uploaded_file, presence: true

  def finalize!
    csv_contents = uploaded_file.download

    CSV.parse(csv_contents, headers: true) do |row|
      space.customers.create!(
        name: row["customer_name"],
        address: row["address"],
        city: row["city"],
        country_code: row["country_code"],
      )
    end
  end
end
