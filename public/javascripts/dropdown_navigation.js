(function() {
  jQuery.fn.dropdownNavigation = function(config){
    function navigate(){
      var loc = jQuery(this).val();
      if("" != loc){ document.location = loc };
      return false;
    };

    return jQuery(this).change(navigate);
  }
})(jQuery);

