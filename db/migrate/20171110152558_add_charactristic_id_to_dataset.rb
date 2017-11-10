class AddCharactristicIdToDataset < ActiveRecord::Migration[5.0]
  def change
    add_reference :datasets, :characteristic, index: true
  end
end
