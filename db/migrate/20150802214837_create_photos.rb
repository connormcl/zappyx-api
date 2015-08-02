class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.integer :sender_id
      t.integer :recipient_id
      t.string :path
      t.string :filename
    end
  end
end
