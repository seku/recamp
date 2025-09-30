# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any time in any environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Load categories from JSON data
require 'json'

def create_categories_from_json(categories_array)
  categories_array.each do |category_data|
    name = category_data['name']
    identifier = category_data['identifier']
    position = category_data['position']
    benefits = category_data['benefits'] || []
    subcategories = category_data['subcategories'] || []
    
    # Find or create the main category
    category = Category.find_or_create_by!(identifier: identifier, parent_id: nil) do |cat|
      cat.name = name
      cat.active = true
      cat.position = position
    end

    # Update existing category if needed
    if category.persisted? && (category.name != name || category.position != position)
      category.update!(name: name, position: position)
    end

    # Create/update benefits for main category
    if benefits.any?
      category.benefits.destroy_all
      benefits.each do |benefit|
        next unless benefit['title'].present? && benefit['desc'].present?
        category.benefits.create!(title: benefit['title'], desc: benefit['desc'])
      end
    end

    puts "Created/Updated category: #{category.name} (#{category.identifier})"
    
    # Create subcategories
    subcategories.each do |subcategory_data|
      subcategory_name = subcategory_data['name']
      subcategory_desc = subcategory_data['desc']
      subcategory_position = subcategory_data['position']
      
      # Create identifier for subcategory based on name
      subcategory_identifier = subcategory_name.downcase
                                              .gsub(/[^a-z0-9\s]/, '')
                                              .gsub(/\s+/, '_')
                                              .strip
      
      subcategory = Category.find_or_create_by!(
        name: subcategory_name, 
        parent_id: category.id
      ) do |subcat|
        subcat.identifier = subcategory_identifier
        subcat.active = true
        subcat.position = subcategory_position
        subcat.description = subcategory_desc
      end
      
      # Update existing subcategory if needed
      if subcategory.persisted?
        if subcategory.identifier != subcategory_identifier || 
           subcategory.position != subcategory_position || 
           subcategory.description != subcategory_desc
          subcategory.update!(
            identifier: subcategory_identifier,
            position: subcategory_position,
            description: subcategory_desc
          )
        end
      end

      # Add benefits for subcategory if present
      if subcategory_data['benefits']
        subcategory.benefits.destroy_all
        subcategory_data['benefits'].each do |benefit|
          next unless benefit['title'].present? && benefit['desc'].present?
          subcategory.benefits.create!(title: benefit['title'], desc: benefit['desc'])
        end
      end
      
      puts "  └── Created/Updated subcategory: #{subcategory.name} (#{subcategory.identifier})"
    end
  end
end

# Load the JSON file
json_file_path = Rails.root.join('db', 'data', 'categories.json')

if File.exist?(json_file_path)
  puts "Loading categories from #{json_file_path}..."
  
  categories_data = JSON.parse(File.read(json_file_path))
  
  # Work with the new JSON structure
  if categories_data['categories']
    create_categories_from_json(categories_data['categories'])
  else
    puts "No 'categories' key found in JSON file"
  end
  
  puts "\n" + "="*50
  puts "Categories seeding completed!"
  puts "Total categories created: #{Category.count}"
  puts "Root categories: #{Category.root_categories.count}"
  puts "Subcategories: #{Category.subcategories.count}"
  puts "="*50
  
  # Display summary
  puts "\nRoot Categories:"
  Category.root_categories.each do |cat|
    puts "  • #{cat.name} (#{cat.identifier}) - #{cat.children.count} subcategories"
  end
else
  puts "Categories JSON file not found at #{json_file_path}"
end