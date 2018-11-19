class Space < ApplicationRecord
  has_many :customer_imports
  has_many :customers
  has_many :users, through: :customers

  validates :title, presence: true
  validates :slug, presence: true
end
