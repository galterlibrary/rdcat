class AddArtifactToDistributions < ActiveRecord::Migration[5.0]
  def change
    add_column :distributions, :artifact, :string
  end
end
