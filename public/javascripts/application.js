// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

(function() {
  jQuery.fn.preview = function(config){
    var root = this;
    var textarea = (config["texrtarea"]) ? jQuery(config["textarea"]) : root.siblings("textarea");

    function showPreview(){
      var data = root.parents("form").serializeArray();
      data = jQuery.grep(data, function(o){return o.name != "_method"});

      try{
        root.find("div.rendered").load(config["url"], data, function(){
            textarea.hide();
            root.
              find("div.rendered").fadeIn("fast").end().
              find("ul li.show").hide().end().
              find("ul li.hide").fadeIn("fast");
        });
      }catch(e){ console.log(e) };
      return false;
    }

    function hidePreview(){
      textarea.fadeIn("fast");
      root.
        find("div.rendered").hide().end().
        find("ul li.hide").hide().end().
        find("ul li.show").fadeIn("fast");
      return false;
    };

    root.find("li.show a.operation").click(showPreview);
    root.find("li.hide a.operation").click(hidePreview).trigger("click");
  };

  jQuery.fn.editContnt = function(config){
    var root = jQuery(this);
    var label = jQuery(config["label"]);
    var hiki_content = jQuery(config["hiki_content"]);
    var html_content = jQuery(config["html_content"]);

    function toggle(){
      if(jQuery(this).val() == "hiki"){
        label.attr("for", hiki_content.find("textarea").attr("id"));
        hiki_content.show(); html_content.hide();
      }else{
        label.attr("for", html_content.find("textarea").attr("id"));
        hiki_content.hide(); html_content.show();
      }
    }

    function linkPaletteCallback(elem){
      if(currentFormatType() == "hiki"){
        var hiki_text = hiki_content.find("textarea:visible");
        if(hiki_text.length > 0){
          var ins  = (elem.get(0).tagName == "IMG") ? "[FIXME]" : "[[" + elem.text() + "|" + elem.attr("href") + "]]";
          insertTextArea(hiki_text, ins);
        }
      }else{
        var fckeditor_id = html_content.find("textarea").attr("id");
        FCKeditorAPI.GetInstance(fckeditor_id).InsertHtml(elem.wrap('<span></span>').parent().html());
      }
    }

    function insertTextArea(textearea, newString){
      var pos = textarea.get(0).selectionStart;
      var text = textarea.val();

      textarea.val(text.substr(0, pos) + newString + text.substr(pos, text.length));
    }

    function currentFormatType(){
      return root.find("input:checked[type=radio][name='page[format_type]']").val();
    }

    root.find("input[type=radio][name='page[format_type]']").change(toggle).filter(":checked").trigger("change");
    hiki_content.find("div.preview").preview(config["preview"]);
    html_content.find("textarea").richEditor(config["richEditor"]);
    console.log(jQuery.extend({}, config["linkPalette"], {"callback":linkPaletteCallback}));
    jQuery(config["palette"]).linkPalette(jQuery.extend({}, config["linkPalette"], {"callback":linkPaletteCallback}));
  };

  jQuery.fn.richEditor = function(config){
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
    };

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

    activateFCKeditor();
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

