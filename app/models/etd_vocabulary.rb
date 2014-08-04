class EtdVocabulary < ActiveRecord::Base

  scope :values_for, -> type { where( "field_type = ?", "#{type}").pluck(:field_value) }
  scope :recent, -> { order("updated_at DESC") }

  validates_presence_of :field_value, :message => "Vocabulary value cannot be empty."

  #pending these methods will be used on autocomplete
  #def results
  #  @results ||= begin
  #    r = Qa::Authorities::Level.where('field_value LIKE ? AND field_type = ?', "#{@q}%", "#{@sub_authority}").limit(10)
  #    r.map { |t| {id: t.id, label: t.term} }
  #  end
  #end
  #
  #def search(q, sub_authority='')
  #  @q = q
  #  @sub_authority= sub_authority
  #end

end
