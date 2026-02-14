class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :firebase_uid, null: false
      t.string :display_name
      t.string :avatar_url

      t.timestamps
    end

    add_index :users, :firebase_uid, unique: true
  end
end
