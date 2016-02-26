class AdministrativeUnits
  ADMINISTRATIVE_UNITS = Locabulary.active_nested_labels_for(predicate_name: 'administrative_units')
  ACTIVE_ADMINISTRATIVE_UNITS = Locabulary.active_items_for(predicate_name: 'administrative_units')

  def initialize(attributes = {})
    @identifier = attributes.fetch(:identifier)
    @selectable = attributes[:selectable]
    @label = attributes.fetch(:label)
    @children = []
  end

  attr_reader :identifier, :selectable, :children, :label

  alias_method :selectable?, :selectable
  alias_method :id, :identifier

  def self.[](value)
    new(
      identifier: value,
      label: value
    )
  end

  def properties(options = {})
    object = ACTIVE_ADMINISTRATIVE_UNITS.detect { |obj| obj.term_label == self.identifier }
    return object
  end

  def to_s
    label
  end

  def self.create_hierarchy
    root_obj = []
    ADMINISTRATIVE_UNITS.each do |key, items|
      root_key, parent_key = key.split('::')
      root  = find_or_create_root(root_obj, root_key)
      parent = nil
      if parent_key
        # Assuming only 3 levels
        # Ex: "University of Notre Dame::College of Engineering::Computer Science and Engineering"
        parent = create_node(root, key, Array.wrap(parent_key).first)
      else
        parent = root
      end
      create_leaf(key, items, parent)
    end
    root_obj
  end

  def self.find_or_create_root(root_obj, root_key)
    root = root_obj.select {|rt| rt.identifier == root_key}.first unless root_obj.blank?
    return root if root
    root = create_root(root_key)
    root_obj << root
    root
  end

  def self.create_root(root_key)
    new(
      identifier: root_key,
      label: root_key,
      selectable: false
    )
  end

  def self.create_node(root, key, parent_key)
    parent = new(
      identifier: key,
      label: parent_key,
      selectable: false
    )
    root.children << parent
    parent
  end

  def self.create_leaf(key, items, parent)
    items.each do |item|
      display_text = item+"—Non-Departmental"
      leaf = new(
        identifier: [key, item].join('::'),
        label: item.eql?(parent.label)?  display_text : item,
        selectable: true
      )
      parent.children << leaf
    end
  end

  def eligible_for_selection?
    self.selectable?
  end
end
