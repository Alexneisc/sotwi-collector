class CreateTweets < ActiveRecord::Migration[5.1]
  def change
    create_table :tweets do |t|
      t.string :tw_id
      t.string :user_id
      t.string :user_name
      t.string :user_screen_name
      t.string :text
      t.timestamps
    end
  end
end
