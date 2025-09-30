class Category < ApplicationRecord
  belongs_to :parent, class_name: 'Category', optional: true
  has_many :children, class_name: 'Category', foreign_key: 'parent_id', dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }
  validates :active, inclusion: { in: [true, false] }
  validates :identifier, presence: true, if: :root?
  validates :identifier, uniqueness: { scope: :parent_id }, allow_blank: true

  serialize :benefits, coder: JSON

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
    "categories/#{identifier}/home.png"
  end

  def main_image_path
    return nil unless identifier.present?
    "categories/#{identifier}/main.png"
  end

  def subcategory_image_path
    return nil unless parent_id.present? && position.present? && parent&.identifier.present?
    
    # Try different extensions in order of preference
    extensions = ['.png', '.jpg', '.jpeg']
    base_path = "categories/#{parent.identifier}/#{position}"
    
    extensions.each do |ext|
      full_path = base_path + ext
      if File.exist?(Rails.root.join('app', 'assets', 'images', full_path))
        return full_path
      end
    end
    
    # Default to .png if no file found
    base_path + '.png'
  end

  def benefits_list
    return [] unless benefits.present?
    case benefits
    when String
      JSON.parse(benefits) rescue []
    when Array
      benefits
    else
      []
    end
  end
end
