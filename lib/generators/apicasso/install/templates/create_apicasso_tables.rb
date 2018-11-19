# Migration from APIcasso tables
class CreateApicassoTables < ActiveRecord::Migration[5.0]
  # Method that generates migration apicasso_keys and apicasso_keys tables
  def change
    execute <<-SQL
      CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    SQL
    # The apicasso_keys schema to creates the table
    # Models will are exposed based on definitions setted in :scope
    # The objects will are manageable through :token
    create_table :apicasso_keys, id: :uuid do |t|
      t.json :scope
      t.integer :scope_type
      t.json :request_limiting
      t.text :token
      t.datetime :deleted_at
      t.timestamps null: false
    end
    # The apicasso_requests schema to creates the table
    # All requests will be saved into this table
    # Thus, available for use in an audit
    create_table :apicasso_requests, id: :uuid do |t|
      t.text :api_key_id
      t.json :object
      t.timestamps null: false
    end
  end
end
