class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events do |t|
      t.string :billetto_id, null: false
      t.string :title, null: false
      t.text :description
      t.string :location
      t.datetime :start_date
      t.datetime :end_date
      t.decimal :price, precision: 10, scale: 2
      t.string :currency
      t.string :organizer
      t.string :image_url
      t.string :url
      t.datetime :fetched_at

      t.timestamps
    end

    add_index :events, :billetto_id, unique: true
    add_index :events, :start_date
    add_index :events, :fetched_at
  end
end
