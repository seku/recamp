module ApplicationHelper
  def category_hero_image_url(category)
    return nil unless category&.identifier.present?

    image_path = category.main_image_path
    return nil unless image_path.present?

    begin
      # Check if the image exists in the file system (Propshaft)
      if File.exist?(Rails.root.join('app', 'assets', 'images', image_path))
        asset_path(image_path)
      else
        nil
      end
    rescue
      nil
    end
  end

  def subcategory_image_url(subcategory)
    return nil unless subcategory&.parent&.identifier.present? && subcategory.position.present?

    image_path = subcategory.subcategory_image_path
    return nil unless image_path.present?

    begin
      # Check if the image exists in the file system (Propshaft)
      if File.exist?(Rails.root.join('app', 'assets', 'images', image_path))
        asset_path(image_path)
      else
        nil
      end
    rescue
      nil
    end
  end
end
