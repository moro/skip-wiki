(function() {
  jQuery.fn.linkPalette = function(config){
    function ResourcePage() {
      this.initialize.apply(this, arguments);
    };

    ResourcePage.each = function(items, per_page, block){
      var numOfPages = Math.floor(items.length / per_page);
      if((items.length % per_page) > 0){ numOfPages++ };

      for(var cur = 0; cur < numOfPages; cur++){
        var pageItem = items.slice(cur * per_page, (cur+1) * per_page);
        block(new ResourcePage(pageItem, cur, numOfPages, per_page));
      }
    };

    ResourcePage.prototype = {
      initialize: function(items, currentPage, numOfPages, per_page){
        this.items = items;
        this.currentPage = currentPage;
        this.numOfPages = numOfPages;
        this.per_page = per_page;
      },
      isLast: function(){
        return (this.currentPage + 1) == this.numOfPages;
      },
      isFirst: function(){
        return this.currentPage == 0;
      },
      needNavigation : function(){
        return !(this.isFirst() && this.isLast());
      }
    };

    var root = jQuery(this);
    var message = config["message"];

    function insertToEditor(elem){
      FCKeditorAPI.GetInstance(config["editor"]).InsertHtml(elem.wrap('<span></span>').parent().html());
      hidePalette();
    }

    function insertLink(label, href){
      return jQuery("<span></span>").text(message["insert_link_label"]).attr("class", "insertLink").click(function(){
        insertToEditor(jQuery("<a></a>").text(label).attr("href", href));
      });
    }

    function insertImage(label, src, filename){
      if(src){
        var img = jQuery("<img />").attr("src", src).attr("alt", label);
        var display = img.clone();
        if(jQuery.browser.msie){ display.attr("width", 200) };
        return display.click(function(){ insertToEditor(img); });
      }else{
        return jQuery("<span></span>").text(filename.substr(0,16));
      }
    }

    function imageRow(data){
      return jQuery("<tr>").
        append(jQuery("<td class='display_name'></td>").append(insertImage(data["display_name"], data["inline"], data["filename"]))).
        append(jQuery("<td class='insert'></td>").append(insertLink(data["display_name"], data["path"])));
    }

    function linkRow(data){
      return jQuery("<tr>").
        append(jQuery("<td class='display_name'></td>").text(data["display_name"])).
        append(jQuery("<td class='insert'></td>").append(insertLink(data["display_name"], data["path"])));
    }

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

    function buildNavigation(page){
      var navigation = jQuery("<div class='navigation'>");
      if(!page.isFirst()){
        navigation.append(jQuery("<span class='prev ss_sprite ss_arrow_left'>前</span>").click(showPrev))
      }
      if(!page.isLast()){
        navigation.append(jQuery("<span class='next ss_sprite ss_arrow_right'>次</span>").click(showNext))
      }
      return navigation;
    }

    function showNext(){
      var cur = root.find("div.palette-page:visible");
      return replace(cur, cur.next("div.palette-page:hidden"));
    }

    function showPrev(){
      var cur = root.find("div.palette-page:visible");
      return replace(cur, cur.prev("div.palette-page:hidden"));
    }

    function replace(hide, show){
      if(show.length > 0){ hide.hide(); show.show() }
      return show;
    }

    function loadItems(palette, url){
      var per_page = 5;
      if(!url) return;

      jQuery.getJSON(url, function(data,stat){
        palette.empty();
        if(data.length == 0) return;

        ResourcePage.each(data, per_page, function(page){
          var t = buildPalettePage(page);
          if(!page.isFirst()){ t.hide() };
          palette.append(t);
        });
      });
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

    function reload(){
      loadAttachments(root.find("#palette-attachments"));
      loadPages(root.find("#palette-pages"));
      root.show();
    }

    function init(){
      root.attr("class", "enabled").draggable({
          handle:"h3",
          containment:root.parents("div.page-content")
        });

      root.find("h3 span").click(hidePalette);
      root.find('#palette-tab').tabs({selected: 0});
      reload()
    }

    root.find("#upload-attachment").iframeUploader(jQuery.extend(config["uploader"], {callback: uploaderCallback}));
    jQuery("span.trigger.operation").one("click", init);
  };
})(jQuery);

