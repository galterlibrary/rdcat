class CreateDatasets < ActiveRecord::Migration[5.0]
  def change
    create_table :datasets do |t|

      t.string :title
      t.text :description
      t.string :license 
      t.references :organization 
      t.string :visibility 
      t.string :state 
      t.string :source 
      t.string :version 
      t.references :author, class: User 
      t.references :maintainer, class: User

      t.timestamps
    end
  end
end
