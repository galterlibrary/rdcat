class CreateDistributions < ActiveRecord::Migration[5.0]
  def change
    create_table :distributions do |t|
      t.references :dataset, index: true

      t.string :uri
      t.string :name
      t.text :description
      t.string :format 

      t.timestamps
    end
  end
end
