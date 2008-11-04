// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

(function() {
  jQuery.fn.preview = function(config){
    var root = this;
    function showPreview(){
      var data = root.parents("form").serializeArray();
      data = jQuery.grep(data, function(o){return o.name != "_method"});

     root.find("div.rendered").load(config["url"], data, function(){
          root.next("textarea").hide();
          root.
            find("div.rendered").fadeIn("fast").end().
            find("ul li.show").hide().end().end().
            find("ul li.hide").fadeIn("fast");
      });
      return false;
    }

    function hidePreview(){
      root.next("textarea").fadeIn("fast");
      root.
        find("div.rendered").hide().end().
        find("ul li.hide").hide().end().end().
        find("ul li.show").fadeIn("fast");
      return false;
    };

    root.find("li.show a.wii_button").click(showPreview);
    root.find("li.hide a.wii_button").click(hidePreview);
    hidePreview();
  };

  jQuery.fn.editor = function(config){
    var root = this;

    function activateFCKeditor(){
      if(!this.oFCKeditor){
        this.oFCKeditor = new FCKeditor(root.attr("id"), "100%", "500") ;
        this.oFCKeditor.BasePath = config["basePath"];
        this.oFCKeditor.ReplaceTextarea() ;
      }
      root.hide().
        siblings(".previewable").hide().end().
        siblings("iframe").fadeIn("fast").end();
    };

    function activateHikiAndPreview(){
      root.fadeIn("fast").
        siblings("iframe").hide().end().
        siblings(".previewable").fadeIn("fast");
    };

    jQuery("#page_format_type_html").click(activateFCKeditor);
    jQuery("#page_format_type_hiki").click(activateHikiAndPreview);

    function dispatch(){
      if(jQuery("[name='page[format_type]']").val() == "html"){
        activateFCKeditor();
      }else{
        activateHikiAndPreview();
      }
    };
    dispatch();
  };

  jQuery.fn.loadMyNote = function(config){
    this.click(function(){
      jQuery(config["notes_elem"]).toggle();
      return false;
    });
    this.one("click", loadMyNote);

    function loadMyNote(){
      jQuery.getJSON(config["url"], {}, appedToMyNote);
      return true;
    }
    function appedToMyNote(json){
      var ul = jQuery(config["notes_elem"]).find("ul");
      jQuery.each(json, function(_,a){
        ul.append("<li><a href='"+a["url"]+"'>"+a["display_name"]+"</a></li>");
      });
    }
  };
})(jQuery);

