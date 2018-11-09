class Space < ApplicationRecord
  has_many :customer_imports
  has_many :customers

  validates :title, presence: true
  validates :slug, presence: true
end
