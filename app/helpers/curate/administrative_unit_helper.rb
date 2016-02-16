module Curate::AdministrativeUnitHelper

  def list_administrative_units(administrative_units,processed_administrative_unit_ids = [], selected_list)
    administrative_units.map do |administrative_unit|
      if administrative_unit.selectable?
        content_tag(:option, value: administrative_unit.identifier, selected:is_selected?(administrative_unit,selected_list), data:{indent:4}) { administrative_unit.label }+ list_administrative_units(administrative_unit.children,processed_administrative_unit_ids)
      else
        content_tag(:option, value: administrative_unit.identifier, disabled:true, data:{indent:2, class:"bold-row"}) { administrative_unit.label } + list_administrative_units(administrative_unit.children,processed_administrative_unit_ids, selected_list)
      end
    end.join.html_safe
  end

  def options_from_collection_for_select_with_attributes(collection, value_method, text_method, attr_name, attr_field, selected = nil)
    options = collection.map do |element|
      [element.send(text_method), element.send(value_method), "data-"+attr_name => element.send(attr_field).size]
    end

    selected, disabled = extract_selected_and_disabled(selected)
    select_deselect = {}
    select_deselect[:selected] = extract_values_from_collection(collection, value_method, selected)
    select_deselect[:disabled] = extract_values_from_collection(collection, value_method, disabled)

    options_for_select(options, select_deselect)
  end

  def is_selected?(administrative_unit,selected_list)
  return selected_list.include?(administrative_unit.id)
  end

  def option_listing(curation_concern)
    select_administrative_unit_ids=[]
    processed_administrative_unit_ids=[]
    administrative_units=Array.wrap(curation_concern.administrative_unit)
    administrative_units.each do |administrative_unit|
      select_administrative_unit_ids << administrative_unit
    end
    options=''
    all_administrative_units = AdministrativeUnits.create_hierarchy
    root = all_administrative_units.first
    root.children.each do |administrative_unit|
      processed_administrative_unit_ids<<administrative_unit.id
      options << options_from_collection_for_select_with_attributes([administrative_unit], "id", "label",'indent', "children", select_administrative_unit_ids) if administrative_unit.eligible_for_selection?
      if administrative_unit.children.present?
          selectable_children=administrative_unit.children.reject {|n| !n.selectable?}
          not_selectable_children=administrative_unit.children.reject {|n| n.selectable?}
          options << "<optgroup label=\"#{administrative_unit.label}\">".html_safe
          options << options_from_collection_for_select_with_attributes(selectable_children, "id", "label", 'indent', "children", select_administrative_unit_ids)
          options << list_administrative_units(not_selectable_children,processed_administrative_unit_ids,select_administrative_unit_ids)
          options << '</optgroup>'.html_safe
      end
    end
    return options
  end

end
