class Department

  class InvalidDepartment < RuntimeError
  end

  def self.all_departments
    DEPARTMENTS.map {|key, attributes| new(attributes) }
  end

  def self.[](key)
    new(DEPARTMENTS.fetch(key))
  end

  attr_reader :id, :identifier, :selectable, :label
  
  alias_method :selectable?, :selectable
  alias_method :name, :label

  def initialize(attributes = {})
    @id = attributes.fetch("key")
    @identifier = attributes.fetch("identifier")
    @selectable = attributes.fetch("selectable")
  end

  def label
    identifier.split("::").last.titleize
  end

  def to_s
    label
  end

  def children
    children=[]
    Department.all_departments.each do |department|
      *parents, child = department.identifier.split("::")
      if self.label.eql?(parents.last)
        children<<  department
      end
    end
    return children
  end

  def parents
    *parents, child = self.identifier.split("::")
    parents.collect{|p|Department[unique_key(p)]}
  end

  def self.for_grouped_select
    select_list=[]
    all_departments.map do |department|
      select_list<<[department, department.children.map { |c| [c.label, c.key] }] unless department.children.empty?
    end
    select_list
  end

  def eligible_for_selection?
    self.selectable? && self.parents.empty?
  end

  private

  #similar to underscore function, since we have space inbetween words
  def unique_key(str)
    str.downcase.gsub(" ","_")
  end

  def enforce_valid_key!(key)
    unless key.in?(DEPARTMENTS.keys)
      raise InvalidDepartment, "The #{key} is not a valid #{self.class} value"
    end
  end

  def department
    departments.fetch(key)
  end

  def departments
    DEPARTMENTS
  end

end