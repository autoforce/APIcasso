class ChangeUsedModelToValidates < ActiveRecord::Migration[5.2]
  def change
    change_column :used_models, :account_id, :integer, null: false
    change_column :used_models, :unit_id, :integer, null: false
    change_column :used_models, :slug, :string, null: false, unique: true
  end
end
