(function() {
  jQuery.fn.iframeUploader = function(config){
    function attachAutoUploaderToInput(){
      var timer = null;
      jQuery(this.contentWindow.document).find("form input").change(function(){
        if(timer){ clearTimeout(timer) };
        var f = jQuery(this).parents("form");
        var file = f.find("input[type=file]");
        var name = f.find("input[type=text]");
        if(file.val().length > 0 && name.val().length > 0){
          var indicator = f.find("td.indicator img").show();
          submit = function(){ f.submit(); f.get(0).reset(); indicator.hide(); name.focus(); timer = null};
          timer = setTimeout(submit, 5*1000);
        }else{
          return;
        }
      });
    }

    var root = jQuery(this);
    var callback = config["callback"];

    jQuery("<div>").addClass("form").append(
      jQuery("<iframe>").attr("src", config["src"]["form"]).load(attachAutoUploaderToInput)
    ).appendTo(root);

    jQuery("<div>").addClass("target").append(
      jQuery("<iframe>").attr("src", config["src"]["target"]).attr("name", config["target"]).
        one("load", function(){ jQuery(this).load(callback) })
    ).appendTo(root);
  }
})(jQuery);

