class CustomerImport < ApplicationRecord
  belongs_to :space

  has_one_attached :uploaded_file

  validates :uploaded_file, presence: true
end
