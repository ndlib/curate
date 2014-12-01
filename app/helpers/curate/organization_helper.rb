module Curate::OrganizationHelper

  def list_organizations(departments,processed_department_ids = [], selected_list)
    departments.map do |department|
      if department.selectable?
        content_tag(:option, value: department.id, selected:is_selected?(department,selected_list), data:{indent:department.parents.size}) { department.label }+ list_organizations(department.children,processed_department_ids)
      else
        content_tag(:option, value: department.id, disabled:true, data:{indent:department.parents.size, class:"bold-row"}) { department.label } + list_organizations(department.children,processed_department_ids, selected_list)
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

  def is_selected?(department,selected_list)
  return selected_list.include?(department.id)
  end

  def opt_listing(curation_concern)
    select_department_ids=[]
    processed_department_ids=[]
    organization=Array(curation_concern.organization)
    organization.each do |department|
      select_department_ids << department
    end
    options=''
    Department.all_departments.each do |department|
      processed_department_ids<<department.id
      options << options_from_collection_for_select_with_attributes([department], "id", "label",'indent', "parents", select_department_ids) if department.eligible_for_selection?
      if department.parents.empty? && department.children.present?
          selectable_children=department.children.reject {|n| !n.selectable?}
          not_selectable_children=department.children.reject {|n| n.selectable?}
          options << "<optgroup label=\"#{department.label}\">".html_safe
          options << options_from_collection_for_select_with_attributes(selectable_children, "id", "label", 'indent', "parents", select_department_ids)
          options << list_organizations(not_selectable_children,processed_department_ids,select_department_ids)
          options << '</optgroup>'.html_safe
      end
    end
    return options
  end

end