class AddFastCategoriesToDataset < ActiveRecord::Migration[5.0]
  def change
    add_column :datasets, :fast_categories, :text, array: true, default: []
  end
end
