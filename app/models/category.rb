class Category < ApplicationRecord
  belongs_to :parent, class_name: 'Category', optional: true
  has_many :children, class_name: 'Category', foreign_key: 'parent_id', dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }
  validates :active, inclusion: { in: [true, false] }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :root_categories, -> { where(parent_id: nil) }
  scope :subcategories, -> { where.not(parent_id: nil) }

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
end
