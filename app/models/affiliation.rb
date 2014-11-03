class Affiliation
  class InvalidAffiliation < RuntimeError
  end

  VALID_ENTITIES = [
      'faculty',
      'staff',
      'graduate',
      'undergraduate',
      'other'
  ]

  def self.values
    @values ||= VALID_ENTITIES.map { |val| new(val) }
  end

  def initialize(key)
    enforce_valid_key!(key)
    @key = key
  end
  attr_reader :key

  def label
    I18n.t!(key, scope: 'curate.organization_affiliation.label')
  end

  def human_name
    I18n.t!(key, scope: 'curate.organization_affiliation.name')
  end

  def to_s
    label
  end

  private

  def enforce_valid_key!(key)
    unless key.in?(VALID_ENTITIES)
      raise InvalidAffiliation, "The #{key} is not a valid #{self.class} value"
    end
  end

end