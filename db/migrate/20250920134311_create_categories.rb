class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.boolean :active, default: true, null: false
      t.references :parent, null: true, foreign_key: { to_table: :categories }

      t.timestamps
    end

    add_index :categories, :name
    add_index :categories, :active
    add_index :categories, [:parent_id, :active]
  end
end
