module ApplicationHelper
  def responsive_image_tag(base_path, widths:, **options)
    image_tag(
      "#{base_path}-#{widths.max}.avif",
      {
        srcset: responsive_image_srcset(base_path, widths: widths),
        sizes: "100vw"
      }.merge(options)
    )
  end

  def responsive_image_srcset(base_path, widths:)
    widths.filter_map do |width|
      path = "#{base_path}-#{width}.avif"
      full_path = Rails.root.join("app/assets/images", path)

      next unless File.exist?(full_path)

      "#{asset_path(path)} #{width}w"
    end.join(", ")
  end
end
