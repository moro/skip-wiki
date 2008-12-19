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
                    url:  form.attr("action"),
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

  jQuery.fn.linkPalette = function(config){
    var root = jQuery(this);
    var message = config["message"];

    function insertToEditor(elem){
      FCKeditorAPI.GetInstance(config["editor"]).InsertElement(elem.get(0));
    }

    function insertLink(label, href){
      return jQuery("<span>").text(message["insert_link_label"]).attr("class", "insertLink").click(function(){
        insertToEditor(jQuery("<a>").text(label).attr("href", href));
      });
    }

    function insertImage(label, src, filename){
      if(src){
        var img = jQuery("<img />").attr("src", src).attr("alt", label);
        return img.clone().attr("width", 80).attr("height", 60).
                 click(function(){ insertToEditor(img); });
      }else{
        return jQuery("<span>").text(filename.substr(0,16));
      }
    }

    function attachmentToTableRow(data){
      var tr = jQuery("<tr>");
      tr.append(jQuery("<td>").append(insertImage(data["display_name"], data["inline"], data["filename"]))).
         append(jQuery("<td>").text(data["display_name"])).
         append(jQuery("<td>").append(insertLink(data["display_name"], data["path"])));

      return tr;
    }

    function loadAttachments(palette, url, label){
      if(!url) return;
      jQuery.getJSON(url, function(data,stat){
        if(data.length == 0) return;
        var tbody = jQuery("<tbody>");
        jQuery.each(data, function(_num_, atmt){
          tbody.append(attachmentToTableRow(atmt["attachment"]));
        });
        palette.
          append(jQuery("<table>").
            append(jQuery("<caption>").text(label)).
            append(tbody));
      });
    }

    function onLoad(){
      root.empty().attr("class", "enabled").draggable().
        append(
          jQuery("<div>").append(
            jQuery("<h3>").text(message["title"]).append(
              jQuery("<span>").text(message["toggle"]).click(function(){ root.find(".palette").toggle() })
            )).append(
            jQuery("<div class='palette' />")
          ));
      loadAttachments(root.find(".palette"), config["note_attachments"], message["note_attachments"]);
      loadAttachments(root.find(".palette"), config["page_attachments"], message["page_attachments"]);
    }
    root.find("span.trigger").one("click", onLoad);
  },

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
          target.removeClass(focusClass);
          target.parents("form").get(0).reset()
        };
      });
  },

  jQuery.fn.manageLabel = function(config){
    var table = jQuery(this).find("table");

    function post(f, callback){
      jQuery.ajax({url: f.attr("action") + ".js",
        type: "POST",
        data: f.serializeArray(),
        success: callback
      });
    }

    function create(){
      var f = jQuery(this);
      jQuery.ajax({url: f.attr("action") + ".js",
        type: "POST",
        data: f.serializeArray(),
        dataType: "json",
        success: function(data, _){ f.get(0).reset(); appendLabel(data); }
      });
      return false;
    }

    function destroy(){
      if(!confirm("削除しますか?")) return false ;
      var f = jQuery(this);
      post(f, function(){f.parents("tr").fadeOut().remove()});

      return false;
    }

    function update(){
      var f = jQuery(this);
      post(jQuery(this), function(){
        var name = f.find("[name='label_index[display_name]']").val();
        var color = f.find("[name='label_index[color]']").val();

        f.parents("tr").find("span.label_badge").
                          attr("style", "border-color:"+color).
                          text(name).end();
        hideOPE(f);
      });
      return false;
    }

    function showOPE(child){
      jQuery(child).parents("td.inplace-edit").
        find("div.show").hide().end().
        find("div.edit").show().end ;
      return false;
    }

    function hideOPE(child){
      jQuery(child).parents("td.inplace-edit").
        find("div.show").show().end().
        find("div.edit").hide().end ;
      return false;
    }

    function appendLabel(data){
      jQuery.each(data, function(_, d){
        if(!d["url"]){
          d["url"] = "/skip_note/notes/"+d["note_id"]+"/label_indices/"+d["id"];
        }
        jQuery.each(table.find("tr div.show"), function(){ hideOPE(this) });

        var row = table.find("tr:first").clone(true).
                    find("span.label_badge").
                      attr("style", "border-color:"+d["color"]).
                      text(d["display_name"]).end().
                    find("td.inplace-edit form").attr("action", d["url"]).
                      find("[name='label_index[display_name]']").val(d["display_name"]).end().
                      find("[name='label_index[color]']").val(d["color"]).end().end().
                    find("td.delete form").attr("action", d["url"]).end();

        table.find("tbody").append(row);
      });
    }

    jQuery(this).find("div.new form").submit(create);
    table.find("td.inplace-edit").
      find("div.show span.op").click(function(){return showOPE(this)}).end().
      find("div.edit span.op").click(function(){return hideOPE(this)}).end().
      find("form").submit(update);
    table.find("td.delete form").submit(destroy);

  }
})(jQuery);

