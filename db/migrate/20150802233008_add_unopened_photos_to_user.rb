class AddUnopenedPhotosToUser < ActiveRecord::Migration
  def change
    add_column :users, :unopened_photos, :integer, array: true, default: []
  end
end
