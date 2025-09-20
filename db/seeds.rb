# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any time in any environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Load categories from JSON data
require 'json'

def create_categories_from_json(categories_hash, parent_category = nil)
  categories_hash.each do |name, subcategories|
    # Find or create the category
    category = Category.find_or_create_by!(name: name, parent: parent_category) do |cat|
      cat.active = true
    end
    
    puts "Created/Found category: #{category.full_path}"
    
    # If this category has subcategories, create them recursively
    if subcategories.is_a?(Hash) && !subcategories.empty?
      create_categories_from_json(subcategories, category)
    end
  end
end

# Load the JSON file
json_file_path = Rails.root.join('db', 'data', 'categories.json')

if File.exist?(json_file_path)
  puts "Loading categories from #{json_file_path}..."
  
  categories_data = JSON.parse(File.read(json_file_path))
  
  # Start with the root level categories
  if categories_data['Kategorie']
    create_categories_from_json(categories_data['Kategorie'])
  end
  
  puts "Categories seeding completed!"
  puts "Total categories created: #{Category.count}"
  puts "Root categories: #{Category.root_categories.count}"
  puts "Subcategories: #{Category.subcategories.count}"
else
  puts "Categories JSON file not found at #{json_file_path}"
end
