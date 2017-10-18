class CreateLicenses < ActiveRecord::Migration[5.0]
  def change
    create_table :licenses do |t|
      t.boolean :domain_content
      t.boolean :domain_data
      t.boolean :domain_software
      t.string :family
      t.string :identifier
      t.string :maintainer
      t.string :od_conformance
      t.string :osd_conformance
      t.string :status
      t.string :title
      t.string :url

      t.timestamps
    end
  end
end
