// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

(function() {
  jQuery.fn.preview = function(config){
    var root = this;
    function showPreview(){
      var data = root.parents("form").serializeArray();
      data = jQuery.grep(data, function(o){return o.name != "_method"});

      try{
        root.find("div.rendered").load(config["url"], data, function(){
            root.next("textarea").hide();
            root.
              find("div.rendered").fadeIn("fast").end().
              find("ul li.show").hide().end().
              find("ul li.hide").fadeIn("fast");
        });
      }catch(e){ console.log(e) };
      return false;
    }

    function hidePreview(){
      root.next("textarea").fadeIn("fast");
      root.
        find("div.rendered").hide().end().
        find("ul li.hide").hide().end().
        find("ul li.show").fadeIn("fast");
      return false;
    };

    root.find("li.show a.operation").click(showPreview);
    root.find("li.hide a.operation").click(hidePreview).trigger("click");
  };

  jQuery.fn.editor = function(config){
    var root = this;
    var form = root.parents("form");

    function api(){
      return FCKeditorAPI.GetInstance(root.attr("id"));
    }

    function activateFCKeditor(){
      if(!this.oFCKeditor){
        this.oFCKeditor = new FCKeditor(root.attr("id"), "100%", config["height"]||"330", "Normal") ;
        this.oFCKeditor.BasePath = config["basePath"];
        this.oFCKeditor.ReplaceTextarea() ;
        if(!config["submit_to_save"]){ addDynamicSave() };
      }
      root.hide().
        siblings(".previewable").hide().end().
        siblings("iframe").fadeIn("fast").end();
    };
/* Hiki
    function activateHikiAndPreview(){
      root.fadeIn("fast").
        siblings("iframe").hide().end().
        siblings(".previewable").fadeIn("fast");
    };
*/
    function addDynamicSave(){
      form.one("submit", createHistory).
           find("input[type=submit]").disable().end().
           find("a.back").click(confirmBack);
    };

    function confirmBack(){
      if(needToSave()){
        return confirm("未保存の更新があります。移動しますか?");
      }else{
        return true;
      }
    }

    function createHistory(){
      var button = jQuery(this);
      return saveHistory("POST", function(req,_){
        form.attr("action", req.getResponseHeader("Location"));
        button.submit( updateHistory );
      });
    };

    function updateHistory(){
      return saveHistory("PUT", function(){});
    }

    function needToSave(){
      return api().IsDirty() &&
             (jQuery.trim( api().GetHTML(true) ).length > 0);
    }

    function saveHistory(method, onSuccess){
      if(!needToSave()){
        alert("No need to save");
        return false;
      }
      var content = api().GetData(true);

      jQuery.ajax({ type: method,
                    url:  form.attr("action") + ".js",
                    data: ({"authenticity_token": $("input[name=authenticity_token]").val(),
                            "history[content]"  : content }),
                    complete : function(req, stat){
                      if(stat == "success"){
                        api().SetData(content, true);
                        onSuccess(req, stat);
                      }
                    } });
      return false;
    };

    function dispatch(){
      if(config["initialState"] == "html"){
        activateFCKeditor();
      }else{
        activateHikiAndPreview();
      }
    };
    dispatch();
  };

  jQuery.fn.reloadLabelRadios = function(config){
    var self = jQuery(this);
    var proto = self.find("li:first").clone().find("input").attr("checked", null).end();
    jQuery.getJSON(config["url"], function(data, status){
      if(status != "success"){ return ; }
      self.empty();
      jQuery.each(data, function(num, l){
        var label = l["label_index"];
        var li = proto.clone()
        var ident = "page_label_index_id_" + label.id;
        li.find("input[type=radio]").attr("id", ident).attr("value", label.id).end().
           find("label").attr("for", ident).
             find("span").attr("style", "border-color:"+label.color).
             text(label.display_name);
        self.append(li);
      });
    });
  };

  jQuery.fn.manageLabel = function(config){
    var table = jQuery(this).find("table");

    function showValidationError(xhr){
      var errors = jQuery.httpData( xhr, "json");
      var ul = jQuery("div.new ul.errors");
      if( (ul.length == 0) ){
        ul = jQuery("<ul class='errors'>");
        ul.appendTo( jQuery("div.new") );
      }
      ul.empty();

      jQuery.each(errors, function(){ jQuery("<li>").text(this.toString()).appendTo(ul) });
    }

    function update(td, _req, _stat){
      var name  = td.find("[name='label_index[display_name]']").val();

      td.find("span.label_badge").text(name);
      return false;
    }

    jQuery.each(table.find("td.inplace-edit"), function(){jQuery(this).aresInplaceEditor({callback:update}) });
  };

  jQuery.fn.aresInplaceEditor = function(config){
    var self = jQuery(this);
    var form = self.find("div.edit form");
    var messages = jQuery.extend({
                     sending: "Sending..."
                   },config["messages"])

    function showIPE(){
      self.find("div.edit").show().siblings("div.show").hide();
    }

    function hideIPE(){
      self.find("div.show").show().siblings("div.edit").hide();
    }

    function submitIPE(){
      try{
        var submitLabel = form.find("input[type=submit]").val();
        jQuery.ajax({url: form.attr("action") + ".js",
          type: "PUT",
          data: form.serializeArray(),
          dataType: "json",
          beforeSend: function(){
            self.find(".indicator").show();
            self.find("span.ipe-cancel").hide();
            if(messages["sending"]){ form.find("input[type=submit]").val( messages["sending"]) };
          },
          complete: function(req, status){
            self.find(".indicator").hide();
            self.find("span.ipe-cancel").show();
            if(messages["sending"]){ form.find("input[type=submit]").val( submitLabel ) };
            hideIPE();
            return config["callback"](self, req, status);
          }
        });
      }catch(e){
        alert(e);
      }
      return false;
    }

    self.
      find("div.show").
        find(".ipe-trigger").click(showIPE).end().end().
      find("div.edit").
        find("form").submit(submitIPE).
          find(".ipe-cancel").click(hideIPE).end().end();

    return self;
  };
})(jQuery);

application = function(){}
application.headOK = function(xhr) {
  return xhr.responseText.match(/\s*/) &&
         xhr.status >= 200 &&
         xhr.status <  300
}

application.post = function(form, parameters) {
  var paramFromForm = {
    url  : form.attr("action") + ".js",
    type : "POST",
    data : form.serializeArray()
  }
  jQuery.ajax(jQuery.extend(paramFromForm, parameters));
}

application.callbacks = {
  pageDisplaynameEditor : function(root, req, stat){
    if(stat == "success"){
      var data = jQuery.httpData( req, "json")["page"];
      root.find("span.title").text(data["display_name"]).effect("highlight", {}, 2*1000);
      root.find("form input[type=text]").val(data["display_name"]);
    } else if(stat == "parsererror" && req.responseText.match(/\s*/)){
      root.find("span.title").text(
        root.find("form input[type=text]").val()
      ).effect("highlight", {}, 2*1000);
    } else if(stat == "error" && req.status == "422"){
      alert(req.responseText);
    }
  },

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
            find("td.display_name").text(atmt["display_name"]).end().
            find("td.size").text(atmt["size"]).end().
            find("td.updated_at").text(atmt["updated_at"]).end().
            find("td.operation a").attr("href", atmt["path"]).end().
        appendTo(tbody);
      });
      tbody.find("tr:first-child").effect("highlight", {}, 2*1000);
    });
  }
};

