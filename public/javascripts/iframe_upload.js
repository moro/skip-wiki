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
    if(!jQuery.isFunction(callback)){ callback = jQuery.fn.iframeUploader.callbacks[callback] } ;

    jQuery("<div>").addClass("form").append(
      jQuery("<iframe>").attr("src", config["src"]["form"]).load(attachAutoUploaderToInput)
    ).appendTo(root);

    jQuery("<div>").addClass("target").append(
      jQuery("<iframe>").attr("src", config["src"]["target"]).attr("name", config["target"]).
        one("load", function(){ jQuery(this).load(callback) })
    ).appendTo(root);
  }

  jQuery.fn.iframeUploader.callbacks = {
    refreshAttachments : function(){
      var url = this.contentWindow.document.location.href;
      jQuery.getJSON(url, null, function(data, status){
        var tbody = $("div.attachments table tbody");
        var tr = tbody.find("tr:nth-child(1)").clone();
        tbody.empty();
        var row = null;
        jQuery.each(data, function(num, json){
          var atmt = json["attachment"];
          row = tr.clone();
          row.find("td.content_type").text(atmt["content_type"]).end().
              find("td.name").text(atmt["filename"]).end().
              find("td.display_name").text(atmt["display_name"]).end().
              find("td.size").text(atmt["size"]).end().
              find("td.updated_at").text(atmt["updated_at"]).end().
              find("td.operation a").attr("href", atmt["path"]).end().
          appendTo(tbody);
        });
        tbody.find("tr:first-child").effect("highlight", {}, 2*1000);
      });
    }
  }
})(jQuery);

