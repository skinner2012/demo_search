class CreateKeyWordSets < ActiveRecord::Migration
  def change
    create_table :key_word_sets do |t|
      t.string :keyword

      t.timestamps
    end
  end
end
