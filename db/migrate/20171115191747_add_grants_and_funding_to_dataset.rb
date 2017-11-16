class AddGrantsAndFundingToDataset < ActiveRecord::Migration[5.0]
  def change
    add_column :datasets, :grants_and_funding, :text
  end
end
