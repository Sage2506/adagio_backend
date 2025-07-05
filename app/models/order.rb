class Order < ApplicationRecord
  belongs_to :user
  belongs_to :alumn
  belongs_to :product
end
