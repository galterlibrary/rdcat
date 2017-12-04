class CreateFastSubjectsTable < ActiveRecord::Migration[5.0]
  def change
    create_table :fast_subjects do |t|
      t.string :label
      t.string :identifier
    end
    add_index :fast_subjects, :label
    add_index :fast_subjects, :identifier, unique: true
  end
end
