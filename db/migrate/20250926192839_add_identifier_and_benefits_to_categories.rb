class AddIdentifierAndBenefitsToCategories < ActiveRecord::Migration[8.0]
  def change
    add_column :categories, :identifier, :string
    add_column :categories, :benefits, :text
    
    add_index :categories, :identifier
    add_index :categories, [:identifier, :parent_id], unique: true
  end
end
