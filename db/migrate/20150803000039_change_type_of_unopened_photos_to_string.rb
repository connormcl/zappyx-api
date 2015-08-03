class ChangeTypeOfUnopenedPhotosToString < ActiveRecord::Migration
  def change
    remove_column :users, :unopened_photos
    add_column :users, :unopened_photos, :string, array: true, default: []
  end
end
