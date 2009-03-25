(function() {
  jQuery.fn.iframeUploader = function(config){
    var submitCallback;
    function attachUploader(){
      var form = jQuery(this.contentWindow.document).find("form");
      if( config['trigger'] == 'submit' ){
        attachSubmitUploader(form);
      }else{
        attachAutoUploaderToInput(form);
      }
    };
    function attachSubmitUploader(f){
      f.submit(function(){
        var indicator = f.find("td.indicator img").show();
        f.get(0).submit();
        indicator.hide();
        var file = f.find("input[type=file]");
        file.focus();
        submitCallback = function(){
          f.get(0).reset();
        };
        return false;
      });
    };
    function attachAutoUploaderToInput(f){
      var timer = null;
      f.find('input').change(function(){
        if(timer){ clearTimeout(timer); };
        var file = f.find("input[type=file]");
        var name = f.find("input[type=text]");
        if(file.val().length > 0 && name.val().length > 0){
          var indicator = f.find("td.indicator img").show();
            submit = function(){ f.submit(); f.get(0).reset(); indicator.hide(); name.focus(); timer = null; };
          timer = setTimeout(submit, 5*1000);
        }else{
          return;
        }
      });
    }
    var afterLoadCallback = function(){
      if(submitCallback){submitCallback.call();}
      callback.call();
    };

    var root = jQuery(this);
    var callback = config["callback"];

    jQuery("<div>").addClass("form").append(
      jQuery("<iframe>").attr("src", config["src"]["form"]).load(attachUploader)
    ).appendTo(root);

    var targetIFrame = jQuery("<iframe>").attr("src", config["src"]["target"]).attr("name", config["target"]).
      one("load", function(){ jQuery(this).load(afterLoadCallback); });

    jQuery("<div>").addClass("target").append(targetIFrame).appendTo(root);

    // IE6対策
    targetIFrame.get(0).contentWindow.name = config["target"];
  };
})(jQuery);

