class AddTitleAndDescToBenefits < ActiveRecord::Migration[8.0]
  def change
    add_column :benefits, :title, :string
    add_column :benefits, :desc, :text
  end
end
