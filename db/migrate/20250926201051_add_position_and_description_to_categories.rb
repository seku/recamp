class AddPositionAndDescriptionToCategories < ActiveRecord::Migration[8.0]
  def change
    add_column :categories, :position, :string
    add_column :categories, :description, :text
    
    add_index :categories, :position
  end
end
