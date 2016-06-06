class AddCategoriesToDatasets < ActiveRecord::Migration[5.0]
  def change
    add_column :datasets, :categories, :text, array: true, default: []
  end
end
