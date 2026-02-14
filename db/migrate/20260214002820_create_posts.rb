class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :body, null: false, limit: 20
      t.integer :reactions_count, default: 0, null: false

      t.timestamps
    end

    add_index :posts, :created_at
  end
end
