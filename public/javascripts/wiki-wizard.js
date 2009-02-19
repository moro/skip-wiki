(function() {
  jQuery.fn.wizard = function(config){
    var root = this;
    function updateConfirmation(klass, value){
      root.find("table.confirmation tr."+klass+" td").text(value);
    };
    function getSelectionLabel(name){
      var checked = root.find("input:radio:checked[name='"+name+"']");
      if(checked.val()){
        return root.find("label[for='"+checked.attr("id")+"']").text();
      }else{
        return null;
      }
    };
    function validatesSelection(key, display_name){
      var val = getSelectionLabel("note["+key+"]")
      if(val){
        updateConfirmation(key, val);
        return true
      }else{
        alert("「" + display_name + "」を選択してください");
        return false;
      }
    };

    function validatesPresenceOf(key, display_name){
      var text = root.find("[name='note["+key+"]']").val();
      if(text.length > 0){
        updateConfirmation(key, text);
        return true;
      }else{
        alert("「" + display_name + "」を入力してください");
        return false;
      }
    }

    root.selectGroupToNext = function(wizard){
      return validatesSelection("group_backend_type", "管理対象");
    };

    root.selectCategoryToNext = function(wizard){
      return validatesSelection("category_id", "カテゴリ");
    };
    root.selectPublicityToNext = function(wizard){
      return validatesSelection("publicity", "公開範囲");
    };
    // TODO 名前直せ
    root.selectInputNameToNext = function(wizard){
      return validatesPresenceOf("display_name", "名称") &&
             validatesPresenceOf("name", "識別名") ;
    };
    root.selectInputDescriptionToNext = function(wizard){
      return validatesPresenceOf("description", "説明");
    };
    root.selectLabelNavigationStyleToNext = function(wizard){
      return validatesSelection("label_navigation_style", "ナビゲーション表示");
    };

    try{
      root.
        find("div.step:not(:first)").hide().end().
        find("div.step").each(function(){
          jQuery(this).
          bind("onForward", function(){
            var jThis = jQuery(this);
            var cName = jThis.attr("class").split(" ")[1] + "ToNext";
            var callback = root[cName] || function(){return true};
            callback(jThis) && jThis.hide().next().fadeIn("fast");
          }).
          bind("onBack", function(){
            jQuery(this).hide().prev().fadeIn("fast");
          }).
          find("button.next").click(function(){
            try{
              jQuery(this).parents("div.step").trigger("onForward");
            }catch(e){ alert(e) }
            return false;
          }).end().
          find("button.previous").click(function(){
            try{
              jQuery(this).parents("div.step").trigger("onBack");
            }catch(e){ alert(e) }
            return false;
          }).end() ;
        });
    }catch(e){
      alert(e.toString());
    }
  }
})(jQuery);

