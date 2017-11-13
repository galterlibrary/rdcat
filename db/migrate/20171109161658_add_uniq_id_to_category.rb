class AddUniqIdToCategory < ActiveRecord::Migration[5.0]
  def change
    add_column :categories, :uniq_id, :string
    add_column :categories, :description, :text
    add_column :categories, :matchers, :string, array: true
    add_index :categories, :matchers, using: 'gin'
  end
end
