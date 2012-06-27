class CreateQuotes < ActiveRecord::Migration
  def change
    create_table :quotes do |t|
      t.integer :category_id
      t.string :quote
      t.string :author
      t.string :tags

      t.timestamps
    end
  end
end
