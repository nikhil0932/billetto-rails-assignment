class CreateVotes < ActiveRecord::Migration[7.2]
  def change
    create_table :votes do |t|
      t.references :event, null: false, foreign_key: true
      t.string :user_id, null: false
      t.string :vote_type, null: false

      t.timestamps
    end

    add_index :votes, [:event_id, :user_id, :vote_type], unique: true, name: 'index_votes_on_event_user_vote'
    add_index :votes, :user_id
  end
end
