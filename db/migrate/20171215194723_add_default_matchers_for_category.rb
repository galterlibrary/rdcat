class AddDefaultMatchersForCategory < ActiveRecord::Migration[5.0]
  def change
    Category.__elasticsearch__.create_index!
    Category.where(matchers: nil).each do |c|
      c.matchers = []
      c.save!
    end
    change_column :categories, :matchers, :string, array: true, default: []
    Category.reindex!
  end
end
