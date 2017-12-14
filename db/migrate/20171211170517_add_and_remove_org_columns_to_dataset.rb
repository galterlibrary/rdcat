class AddAndRemoveOrgColumnsToDataset < ActiveRecord::Migration[5.0]
  def change
    remove_column :datasets, :organization_id, :integer

    Organization.delete_all
    remove_column :organizations, :abbreviation, :string
    remove_column :organizations, :email, :string
    add_column :organizations, :org_type, :integer, null: false
    add_column :organizations, :group_name, :string

    create_table :dataset_organizations do |t|
      t.belongs_to :dataset, index: true, foreign_key: true, null: false
      t.belongs_to :organization, index: true, foreign_key: true, null: false
      t.timestamps null: false
    end
  end
end
