class Benefit < ApplicationRecord
  belongs_to :category

  validates :title, presence: true, length: { maximum: 255 }
  validates :desc, presence: true
end
