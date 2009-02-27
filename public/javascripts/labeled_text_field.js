(function() {
  jQuery.fn.labeledTextField = function(config){
    var target = jQuery(this);
    var focusClass = config["focusClass"] || "focus";
    var message = config["message"];

    target.parents("form").get(0).reset();
    if(target.val() != message){ target.addClass(focusClass); };

    target.focus(function(){
        target.addClass(focusClass);
        if(target.val() == message){ target.val("") };
      });
    target.blur(function(){
        if(target.val() == ""){
          target.removeClass(focusClass).val(message);
        };
      });
  };
})(jQuery);

