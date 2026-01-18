class Category < ApplicationRecord
  belongs_to :parent, class_name: 'Category', optional: true
  has_many :children, class_name: 'Category', foreign_key: 'parent_id', dependent: :destroy
  has_many :benefits, dependent: :destroy

  accepts_nested_attributes_for :benefits, allow_destroy: true

  validates :name, presence: true, length: { maximum: 255 }
  validates :active, inclusion: { in: [true, false] }
  validates :identifier, presence: true, if: :root?
  validates :identifier, uniqueness: { scope: :parent_id }, allow_blank: true

  # serialize :benefits, coder: JSON

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :root_categories, -> { where(parent_id: nil) }
  scope :subcategories, -> { where.not(parent_id: nil) }
  scope :ordered_by_position, -> { order(:position) }

  def root?
    parent_id.nil?
  end

  def has_children?
    children.exists?
  end

  def ancestors
    return [] if root?
    [parent] + parent.ancestors
  end

  def descendants
    children + children.flat_map(&:descendants)
  end

  def full_path
    ancestors.reverse.map(&:name).push(name).join(' > ')
  end

  def home_image_path
    return nil unless identifier.present?
    "categories/#{identifier}/home"
  end

  def main_image_path
    return nil unless identifier.present?
    "categories/#{identifier}/main"
  end


  def subcategory_image_path(subcategory_position)
    # version in case not every subcategory has image
    # but DIr.glob is slow should be replaced by caching
    # path = "categories/#{identifier}/#{subcategory_position}"
    # pattern = Rails.root.join("app/assets/images", "#{path}-*.*")

    # Dir.glob(pattern).any? ? path : nil
    #
    "categories/#{identifier}/#{subcategory_position}"
  end
end
