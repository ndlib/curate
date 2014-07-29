// This widget manages the adding and removing of repeating fields.
// There are a lot of assumptions about the structure of the classes and elements.
// These assumptions are reflected in the MultiValueInput class.
//
(function($){
  $.widget( "curate.manage_sections", {
    options: {
      change: null,
      add: null,
      remove: null
    },

    _create: function() {
      this.element.addClass("managed");
      $('.section.field-wrapper', this.element).addClass("input-append");
      this.controls = $("<span class=\"field-controls\">");
      this.remover  = $("<button class=\"btn btn-danger remove\"><i class=\"icon-white icon-minus\"></i><span>Remove</span></button>");
      this.adder    = $("<button class=\"btn btn-success add\" id=\"section_add_button\"><i class=\"icon-white icon-plus\"></i><span>Add</span></button>");

      $('.section.field-wrapper', this.element).append(this.controls);
      $('.section.field-wrapper:not(:last-child) .field-controls', this.element).append(this.remover);
      $('.field-controls:last', this.element).append(this.adder);

      this._on( this.element, {
        "click .remove": "remove_from_list",
        "click .add": "add_to_section_list"
      });

      var $last_line = $('.section.field-wrapper', this.element).last();
      var $last_element_val = $last_line.children('div').first().children('div').children('input').val();
      if( $last_element_val ){
        $( '#section_add_button').trigger( 'click' );
      } 
    },

    add_to_section_list: function( event ) {
      event.preventDefault();

      var num = $('.section.field-wrapper').length;
      var $activeField = $(event.target).parents('.section.field-wrapper'),
          $activeFieldControls = $activeField.children('.field-controls'),
          $removeControl = this.remover.clone(),
          $newField = $activeField.clone(),
          $listing = $('.listing', this.element),
          $warningSpan  = $("<span class=\'message warning\'>cannot add new empty field</span>");
      if ($activeField.children('div').first().children('div').children('input').val() === '') {
          $listing.children('.warning').remove();
          $listing.append($warningSpan);
      }
      else{
        $listing.children('.warning').remove();
        $('.add', $activeFieldControls).remove();
        $('.remove', $activeFieldControls).remove();
        $activeFieldControls.prepend($removeControl);
        $newChild1 = $newField.children('div').first().children('div').children('input').attr('id', 'etd_contributor_attributes_'+num+'_contributor').attr('name', 'etd[contributor_attributes][' + num + '][contributor][]');
        $newChild2 = $newField.children('div').last().children('div').children('input').attr('id', 'etd_contributor_attributes_'+num+'_role').attr('name', 'etd[contributor_attributes][' + num + '][role][]');
        $newChild1.val('');
        $newChild2.val('');
        $listing.append($newField);
        $('.remove', $newField).remove();
        $newChild1.first().focus();
        this._trigger("add");
      }
    },

    remove_from_list: function( event ) {
      event.preventDefault();

      $(event.target)
        .parents('.section.field-wrapper')
        .remove();

      this._trigger("remove");
    },

    _destroy: function() {
      this.actions.remove();
      $('.section.field-wrapper', this.element).removeClass("input-append");
      this.element.removeClass( "managed" );
    }
  });
})(jQuery);
