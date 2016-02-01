# This migration comes from curate_engine (originally 20140722164917)
class CreateEtdVocabularies < ActiveRecord::Migration
  def change
    create_table :etd_vocabularies do |t|
      t.string :field_type
      t.string :field_value
      t.timestamps
    end
  end
end
