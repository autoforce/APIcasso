class CreateApicassoTables < ActiveRecord::Migration[5.0]
  def change
    execute <<-SQL
      CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    SQL
    create_table :apicasso_keys, id: :uuid do |t|
      t.json :scope
      t.integer :scope_type
      t.json :request_limiting
      t.text :token
      t.datetime :deleted_at
      t.timestamps null: false
    end
    create_table :apicasso_requests, id: :uuid do |t|
      t.text :api_key_id
      t.json :object
      t.timestamps null: false
    end
  end
end
