class CreateEtdVocabularies < ActiveRecord::Migration
  def change
    create_table :etd_vocabularies do |t|
      t.string :field_type
      t.string :field_value
      t.timestamps
    end
  end
end
