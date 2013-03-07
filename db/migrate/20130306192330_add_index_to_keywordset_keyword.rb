class AddIndexToKeywordsetKeyword < ActiveRecord::Migration
  def change
    add_index :key_word_sets, :keyword, unique: true
  end
end
