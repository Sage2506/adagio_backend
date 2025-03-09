class Order < ApplicationRecord
  belongs_to :user
  belongs_to :alumn
  belongs_to :payment
  belongs_to :product
end
