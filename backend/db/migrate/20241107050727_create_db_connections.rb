class CreateDbConnections < ActiveRecord::Migration[7.2]
  def change
    create_table :db_connections do |t|
      t.timestamps
      t.string :name, null: false
      t.string :db_type, null: false
      t.string :host, null: false
      t.integer :port, null: false
      t.string :login_name, null: false
      t.string :default_database_name, null: false
      t.string :password
      t.string :parameters
      t.integer :timeout, default: 5000
      t.boolean :use_ssl, default: false
      t.string :ssl_key
      t.string :ssl_cert
      t.string :ssl_ca
      t.text :description
    end
    add_index :db_connections, :name, unique: true
  end
end
