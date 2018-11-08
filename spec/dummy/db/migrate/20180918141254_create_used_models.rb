class CreateUsedModels < ActiveRecord::Migration[5.2]
  def change
    create_table :used_models do |t|
      t.boolean :active, default: true
      t.integer :account_id
      t.integer :unit_id
      t.string :brand
      t.string :name
      t.string :slug
      t.string :model
      t.string :version
      t.integer :model_year
      t.string :production_year
      t.string :kind
      t.boolean :new_vehicle, default: false
      t.string :old_price
      t.integer :price_value
      t.string :price
      t.string :category
      t.string :transmission
      t.integer :km_value
      t.string :km
      t.string :plate
      t.string :color
      t.integer :doors
      t.integer :fuel
      t.string :fuel_text
      t.text :note
      t.string :chassis
      t.boolean :shielded, default: false
      t.boolean :featured, default: false
      t.string :integrator
      t.integer :ordination, default: 0
      t.integer :visits, default: 0
      t.integer :bait_id, default: 6
      t.integer :fipe_id
      t.string :identifier
      t.string :synced_at
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
