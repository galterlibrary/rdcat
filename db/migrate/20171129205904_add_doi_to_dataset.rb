class AddDoiToDataset < ActiveRecord::Migration[5.0]
  def change
    add_column :datasets, :doi, :string
  end
end
