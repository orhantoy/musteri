class Space < ApplicationRecord
  has_many :customer_imports
  has_many :customers
end
