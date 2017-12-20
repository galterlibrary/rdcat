class AddAttribsToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :orchid, :string
    add_column :users, :scopusid, :string
    add_column :users, :affiliations, :string, array: true, default: []
    add_column :users, :title, :string
    add_column :users, :work_address, :string
  end
end
