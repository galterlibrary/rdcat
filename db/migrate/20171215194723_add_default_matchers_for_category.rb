class AddDefaultMatchersForCategory < ActiveRecord::Migration[5.0]
  def change
    if !Rails.env.test?
      Category.__elasticsearch__.create_index!

      Category.where(matchers: nil).each do |c|
        c.matchers = []
        c.save!
      end
    end
    change_column :categories, :matchers, :string, array: true, default: []
    if !Rails.env.test?
      Category.reindex!
    end
  end
end
