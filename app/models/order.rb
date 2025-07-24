class Order < ApplicationRecord
  has_one :alumn
  enum :status, %w[ pending partial paid]
end
