# encoding: UTF-8
# Helper methods used across the curation concerns
module CurateHelper
  def support_email_link(options = {})
    mail_to(t('sufia.help_email'), t('sufia.help_email'), {subject: t('sufia.help_email_subject')}.merge(options)).html_safe
  end

  def file_size_warning
    markup = <<-html
    <p class="alert alert-block">
      <strong>Please Note:</strong><br />
      For files larger than #{t('sufia.supported_file_upload_size')} please contact #{support_email_link.html_safe} for assistance.
    </p>
    html
    markup.html_safe
  end

  # Loads the object and returns its title
  def collection_title_from_pid(value)
    begin
      c = Collection.load_instance_from_solr(value)
    rescue => e
      logger.warn("WARN: Helper method collection_title_from_pid raised an error when loading #{value}.  Error was #{e}")
    end
    c.nil? ? value : c.title
  end

  # Loads the person object and returns their name
  # In this case, the value is in the format: info:fedora/<PID>
  # So used split
  def creator_name_from_pid(value)
    begin
      p = Person.load_instance_from_solr(value.split("/").last)
    rescue => e
      logger.warn("WARN: Helper method create_name_from_pid raised an error when loading #{value}.  Error was #{e}")
    end
    p.nil? ? value : p.name
  end

  def construct_page_title(*elements)
    (elements.flatten.compact + [application_name]).join(" // ")
  end

  def curation_concern_page_title(curation_concern)
    if curation_concern.persisted?
      construct_page_title(curation_concern.title, "#{curation_concern.human_readable_type} [#{curation_concern.to_param}]")
    else
      construct_page_title("New #{curation_concern.human_readable_type}")
    end
  end

  def default_page_title
    text = controller_name.singularize.titleize
    if action_name
      text = "#{action_name.titleize} " + text
    end
    construct_page_title(text)
  end

  # options[:include_empty]
  def curation_concern_attribute_to_html(curation_concern, method_name, label = nil, options = {})
    markup = ""
    label ||= derived_label_for(curation_concern, method_name)
    subject = curation_concern.public_send(method_name)
    return markup if !subject.present? && !options[:include_empty]
    markup << %(<tr><th>#{label}</th>\n<td><ul class='tabular'>)
    [subject].flatten.compact.each do |value|
      if method_name == :rights
        # Special treatment for license/rights.  A URL from the Sufia gem's config/sufia.rb is stored in the descMetadata of the
        # curation_concern.  If that URL is valid in form, then it is used as a link.  If it is not valid, it is used as plain text.
        begin
          parsed_uri = URI.parse(value)
        rescue
          parsed_uri = nil
        end

        if parsed_uri.nil?
          markup << %(<li class="attribute #{method_name}">#{h(richly_formatted_text(value))}</li>\n)
        else
          markup << <<-html
            <li class="attribute #{method_name}">
              <a href=#{h(value)} target="_blank"> #{h(Sufia.config.cc_licenses_reverse[value])}</a>
            </li>
          html
        end
      else
        markup << %(<li class="attribute #{method_name}">#{h(richly_formatted_text(value))}</li>\n)
      end
    end
    markup << %(</ul></td></tr>)
    markup.html_safe
  end

  def curation_concern_attribute_to_formatted_text(curation_concern, method_name, label = nil, options = { class: 'descriptive-text' })
    markup = ""
    label ||= derived_label_for(curation_concern, method_name)
    subject = curation_concern.public_send(method_name)
    return markup if subject.blank?
    markup << %(<h2 class="#{method_name}-label">#{label}</h2>\n<section class="#{method_name}-list">\n)
    [subject].flatten.compact.each do |value|
      markup << %(<article class="#{method_name} #{options[:class]}">\n#{richly_formatted_text(value)}\n</article>\n)
    end
    markup << %(</section>)
    markup.html_safe
  end

  def derived_label_for(curation_concern, method_name)
    curation_concern.respond_to?(:label_for) ? curation_concern.label_for(method_name) : method_name.to_s.humanize.titlecase
  end
  private :derived_label_for

  def classify_for_display(curation_concern)
    curation_concern.human_readable_type.downcase
  end

  def link_to_edit_permissions(curation_concern, solr_document = nil)
    markup = <<-HTML
      <a href="#{edit_polymorphic_path_for_asset(curation_concern)}" id="permission_#{curation_concern.to_param}">
        #{permission_badge_for(curation_concern, solr_document)}
      </a>
    HTML
    markup.html_safe
  end

  def permission_badge_for(curation_concern, solr_document = nil)
    solr_document ||= curation_concern.to_solr
    dom_label_class, link_title, qualifier = extract_dom_label_class_and_link_title(solr_document)
    %(<span class="label #{dom_label_class}" title="#{link_title}">#{link_title}</span>#{qualifier}).html_safe
  end

  def polymorphic_path_args(asset)
    # A better approximation, but we still need one location for this information
    # either via routes or via the initializer of the application
    if asset.class.included_modules.include?(CurationConcern::Model)
      [:curation_concern, asset]
    else
      asset
    end
  end

  def polymorphic_path_for_asset(asset)
    polymorphic_path(polymorphic_path_args(asset))
  end

  def edit_polymorphic_path_for_asset(asset)
    edit_polymorphic_path(polymorphic_path_args(asset))
  end

  # This converts a collection of objects to a 2 dimensional array having keys accessed via the key_method on the objects
  # and the values accessed via the value_method on the objects.
  # key_method and value_method are strings which are the names of the methods or accessors or attributes by
  # which the value of the key and the value of the array value can be acquired for each of the objects.  These
  # values for the key and the value are placed into the returned array.
  # EXAMPLE:  Oh is class which has methods a, b, c, d, e on it (Oh.a, Oh.b, etc.).  You want an array of
  #           a collection of Ohs.  The array would contain the value of b as the key and the value of e as the corresponding value.
  #           The collection of Ohs is in the variable ohList.
  #           ohArray = objects_to_array(ohList, 'b', 'e')
  def objects_to_array(collection, key_method, value_method)
    collection.map do |element|
      [get_value_for(element, key_method), get_value_for(element, value_method)]
    end
  end

  # This is a private helper method which given an item (an object), retrieves the value of some member on it by way of
  # what is specified in the by_means_of parameter.  by_means_of is the string name of a method, an accessor, an
  # attribute, or other mechanism which can access that information on the item.
  def get_value_for(item, by_means_of)
    by_means_of.respond_to?(:call) ? by_means_of.call(item) : item.send(by_means_of)
  end
  private :get_value_for

  def extract_dom_label_class_and_link_title(document)
    hash = document.stringify_keys
    dom_label_class = 'label-important'
    link_title = 'Private'
    qualifier = ''

    if hash[Hydra.config[:permissions][:read][:group]].present?
      embargo_release_date = hash[Hydra.config[:permissions][:embargo_release_date]]
      if embargo_release_date.present?
        dom_label_class = 'label-warning'
        link_title = 'Under Embargo'
        qualifier = " until #{date_from_solr_field(embargo_release_date)}"
      elsif hash[Hydra.config[:permissions][:read][:group]].include?('public')
        dom_label_class = 'label-success'
        link_title = 'Open Access'
      elsif hash[Hydra.config[:permissions][:read][:group]].include?('registered')
        dom_label_class = 'label-info'
        link_title = t('sufia.institution_name')
      end
    end
    [dom_label_class, link_title, qualifier]
  end
  private :extract_dom_label_class_and_link_title

  def date_from_solr_field(date_string)
    date_string.split('T').first
  end
  private :date_from_solr_field

  def auto_link_without_protocols(url)
    link = (url =~ %r(/\A(?i)[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/)) ? 'http://' + url : url
    auto_link(link, :all)
  end

  def richly_formatted_text(text)
    return if text.blank?
    markup = Curate::TextFormatter.call(text: text)
    markup.html_safe unless markup.nil?
  end

  def escape_html_for_solr_text(text)
    return if text.nil?
    modified_text = CGI.escapeHTML(text)
    CGI.unescapeHTML(CGI.unescapeHTML(modified_text))
  end
end
