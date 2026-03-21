class AddBrewingMethodToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :brewing_method, :string
  end
end
