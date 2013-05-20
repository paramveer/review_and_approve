class CreateCacheRecords < ActiveRecord::Migration
  def change
    create_table :cache_records do |t|
      t.string  :key
      t.text :cache_data     
      t.timestamps
    end

    add_index :cache_records, :key
  end
end