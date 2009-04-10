(function() {
  jQuery.fn.paletteTab = function(url, options){
    var insertToEditor = options["callback"];
    var messages = options["messages"];
    var per_page = options["per_page"];

    function ResourcePage() {
      this.initialize.apply(this, arguments);
    };

    ResourcePage.each = function(items, per_page, block){
      var numOfPages = Math.floor(items.length / per_page);
      if((items.length % per_page) > 0){ numOfPages++ };

      for(var cur = 0; cur < numOfPages; cur++){
        var pageItem = items.slice(cur * per_page, (cur+1) * per_page);
        block(new ResourcePage(pageItem, cur, numOfPages));
      }
    };

    ResourcePage.prototype = {
      initialize: function(items, currentPage, numOfPages){
        this.items = items;
        this.currentPage = currentPage;
        this.numOfPages = numOfPages;
      },
      isLast: function(){ return (this.currentPage + 1) == this.numOfPages; },
      isFirst: function(){ return this.currentPage == 0; },
      needNavigation : function(){ return !(this.isFirst() && this.isLast()); }
    };

    function buildPalettePage(page){
      var pageDOM = jQuery("<div class='palette-page'>");
      if(page.needNavigation()){ pageDOM.append(buildNavigation(page)) }

      var tbody = jQuery("<tbody>")
      jQuery.each(page.items, function(_num_, item){
        var data = (function(){for(name in item) return item[name]})();
        tbody.append( (data["inline"]) ? imageRow(data) : linkRow(data) );
      });
      return pageDOM.append( jQuery("<table>").append(tbody) );
    }

    function insertLink(label, href){
      return jQuery("<span></span>").text(messages["insert_link_label"]).attr("class", "insertLink").click(function(){
        insertToEditor(jQuery("<a></a>").text(label).attr("href", href));
      });
    }

    function linkRow(data){
      return jQuery("<tr>").
        append(jQuery("<td class='display_name'></td>").text(data["display_name"])).
        append(jQuery("<td class='insert'></td>").append(insertLink(data["display_name"], data["path"])));
    }

    function imageRow(data){
      return jQuery("<tr>").
        append(jQuery("<td class='display_name'></td>").append(insertImage(data["display_name"], data["inline"], data["filename"]))).
        append(jQuery("<td class='insert'></td>").append(insertLink(data["display_name"], data["path"])));
    }

    function insertImage(label, src, filename){
      if(src){
        var img = jQuery("<img />").attr("src", src).attr("alt", label);
        var display = img.clone();
        if(jQuery.browser.msie){ display.attr({width:"200", height:"150"}) };
        return display.click(function(){ insertToEditor(img); });
      }else{
        return jQuery("<span></span>").text(filename.substr(0,16));
      }
    }

    function buildNavigation(page){
      var navigation = jQuery("<div class='navigation'>");
      if(!page.isFirst()){
        navigation.append(jQuery("<span></span>").addClass('prev ss_sprite ss_arrow_left').text(messages["navi_prev"]).click(showPrev))
      }
      if(!page.isLast()){
        navigation.append(jQuery("<span></span>").addClass('next ss_sprite ss_arrow_right').text(messages["navi_next"]).click(showNext))
      }
      return navigation;
    }

    function showNext(){
      var cur = palette.find("div.palette-page:visible");
      return toggleNavigation(cur, cur.next("div.palette-page:hidden"));
    }

    function showPrev(){
      var cur = palette.find("div.palette-page:visible");
      return toggleNavigation(cur, cur.prev("div.palette-page:hidden"));
    }

    function toggleNavigation(hide, show){
      if(show.length > 0){ hide.hide(); show.show() }
      return show;
    }

    function buildPaletteTab(data, stat){
      palette.find("div.indicator").hide();
      if(data.length == 0) return;
      ResourcePage.each(data, per_page, function(page){
        var t = buildPalettePage(page);
        if(!page.isFirst()){ t.hide() };
        palette.append(t);
      });
    }

    var palette = jQuery(this);
    palette.find("div.palette-page").remove();
    palette.find("div.indicator").show();

    jQuery.getJSON(url, buildPaletteTab);

    return palette;
  };

  jQuery.fn.linkPalette = function(config){
    var root = jQuery(this);
    var messages = config["messages"];
    var tab_config = {
      callback : function(elem){ config["callback"](elem); hidePalette(); },
      per_page : 5,
      messages : messages["tab"]
    };

    function loadItems(palette, url){
      if(!url) return;
      palette.paletteTab(url, tab_config);
    }

    function hidePalette(){
      root.hide();
      jQuery("span.trigger.operation").one("click", reload);
    }

    function loadAttachments(palette){
      loadItems(palette, config["url"]["attachments"]);
    }

    function loadPages(palette){
      loadItems(palette, config["url"]["pages"]);
    }

    function uploaderCallback(){
      loadAttachments(root.find("#palette-attachments"));
      jQuery("a[href='#palette-attachments']").trigger("click");
    }

    function initPageSearchField(palette){
      palette.find("span.operation").click(function(){loadPages(palette)});
      palette.find("form").submit(function(){
        try{
          loadItems(palette, config["url"]["pages"] + "?" + jQuery(this).serialize());
        }catch(e){console.log(e)};
        return false;
      }).
      find("input[type=text]").labeledTextField({message:messages["page_search"]["keyword"]});
    }

    function reload(){
      loadAttachments(root.find("#palette-attachments"));
      loadPages(root.find("#palette-pages"));
      root.find("#palette-pages form input[type=text]").val("").trigger("blur");
      root.show();
    }

    var activate = reload;

    function init(ev){
      root.attr("class", "enabled").draggable({
          handle:"h3",
          containment:root.parents("div.page-content")
        });

      root.css("top", ev.pageY + "px");
      root.css("left", ev.pageX + "px");

      root.find("h3 span").click(hidePalette);
      root.find('#palette-tab').tabs({selected: 0});
      initPageSearchField(root.find("#palette-pages"));
      activate()
    }

    root.find("#upload-attachment").iframeUploader(jQuery.extend(config["uploader"], {callback: uploaderCallback}));
    jQuery("span.trigger.operation").one("click", init);
  };
})(jQuery);

