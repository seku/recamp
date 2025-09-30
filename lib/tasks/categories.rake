namespace :categories do
  desc "Clean up duplicate categories without identifiers"
  task cleanup: :environment do
    puts "Cleaning up duplicate categories..."
    
    # Find categories without identifiers (old ones)
    categories_without_identifiers = Category.where(identifier: [nil, ""])
    
    puts "Found #{categories_without_identifiers.count} categories without identifiers"
    
    categories_without_identifiers.each do |category|
      puts "Removing category: #{category.name} (ID: #{category.id}) - Children: #{category.children.count}"
      category.destroy
    end
    
    puts "Cleanup completed!"
    puts "Remaining categories: #{Category.count}"
    puts "Root categories: #{Category.root_categories.count}"
    puts "Subcategories: #{Category.subcategories.count}"
    
    puts "\nRoot Categories:"
    Category.root_categories.each do |cat|
      puts "  • #{cat.name} (#{cat.identifier}) - #{cat.children.count} subcategories"
    end
  end
  
  desc "Reset and reload all categories from JSON"
  task reset: :environment do
    puts "Resetting all categories..."
    
    Category.destroy_all
    
    puts "All categories removed. Reloading from JSON..."
    
    # Load categories from JSON data
    require 'json'
    
    def create_categories_from_json(categories_array)
      categories_array.each do |category_data|
        name = category_data['name']
        identifier = category_data['identifier']
        benefits = category_data['benefits'] || []
        subcategories = category_data['subcategories'] || []
        
        # Create the main category
        category = Category.create!(
          name: name,
          identifier: identifier,
          active: true,
          benefits: benefits,
          parent_id: nil
        )
        
        puts "Created category: #{category.name} (#{category.identifier})"
        
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
          
          subcategory = Category.create!(
            name: subcategory_name,
            identifier: subcategory_identifier,
            parent_id: category.id,
            active: true,
            position: subcategory_position,
            description: subcategory_desc,
            benefits: [{ 'title' => 'Description', 'desc' => subcategory_desc }]
          )
          
          puts "  └── Created subcategory: #{subcategory.name} (#{subcategory.identifier})"
        end
      end
    end
    
    # Load the JSON file
    json_file_path = Rails.root.join('db', 'data', 'categories.json')
    
    if File.exist?(json_file_path)
      categories_data = JSON.parse(File.read(json_file_path))
      
      if categories_data['categories']
        create_categories_from_json(categories_data['categories'])
      end
      
      puts "\n" + "="*50
      puts "Categories reset completed!"
      puts "Total categories created: #{Category.count}"
      puts "Root categories: #{Category.root_categories.count}"
      puts "Subcategories: #{Category.subcategories.count}"
      puts "="*50
      
      puts "\nRoot Categories:"
      Category.root_categories.each do |cat|
        puts "  • #{cat.name} (#{cat.identifier}) - #{cat.children.count} subcategories"
      end
    else
      puts "Categories JSON file not found at #{json_file_path}"
    end
  end
  
  desc "Show category statistics"
  task stats: :environment do
    puts "Category Statistics:"
    puts "=" * 40
    puts "Total categories: #{Category.count}"
    puts "Root categories: #{Category.root_categories.count}"
    puts "Subcategories: #{Category.subcategories.count}"
    puts "Active categories: #{Category.active.count}"
    puts "Inactive categories: #{Category.inactive.count}"
    puts "Categories with identifiers: #{Category.where.not(identifier: [nil, '']).count}"
    puts "Categories without identifiers: #{Category.where(identifier: [nil, '']).count}"
    
    puts "\nRoot Categories:"
    Category.root_categories.order(:name).each do |cat|
      identifier_info = cat.identifier.present? ? cat.identifier : "NO IDENTIFIER"
      puts "  • #{cat.name} (#{identifier_info}) - #{cat.children.count} subcategories"
    end
  end
end