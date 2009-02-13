class AddDataToCategories < ActiveRecord::Migration
  def self.up
    Category.create(:name => "Movie")
    Category.create(:name => "TV")
    Category.create(:name => "Music")
    Category.create(:name => "Photos")
    Category.create(:name => "Documents")
    Category.create(:name => "Other")
  end

  def self.down
    Category.delete(:name => "Movie")
    Category.create(:name => "TV")
    Category.delete(:name => "Music")
    Category.delete(:name => "Photos")
    Category.delete(:name => "Documents")
    Category.delete(:name => "Other")
  end
end
