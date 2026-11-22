class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :clerk_id, null: false
      t.string :email, null: false
      t.string :first_name
      t.string :last_name
      t.string :profile_image_url
      t.datetime :last_sign_in_at
      t.string :last_sign_in_ip

      t.timestamps
    end

    add_index :users, :clerk_id, unique: true
    add_index :users, :email, unique: true
    add_index :users, :updated_at
  end
end
