
FCKConfig.EditorAreaCSS = FCKConfig.BasePath + '../../../stylesheets/application.css' ;

FCKConfig.Plugins.Add( 'autogrow' ) ;
FCKConfig.Plugins.Add( 'dragresizetable' );
FCKConfig.AutoGrowMax = 1000 ;

FCKConfig.BodyId = 'fckedit' ;
FCKConfig.BodyClass = 'rich_style' ;

FCKConfig.DefaultLanguage               = 'ja' ;
FCKConfig.SkinPath = FCKConfig.BasePath + 'skins/silver/';

FCKConfig.ToolbarSets["Normal"] = [
        ['Cut','Copy','Paste','PasteText','PasteWord'],
        ['Undo','Redo','RemoveFormat'],
        ['Bold','Italic','Underline','StrikeThrough'],
        ['OrderedList','UnorderedList'],
        ['JustifyLeft','JustifyCenter','JustifyRight','JustifyFull'],
        ['TextColor','BGColor'],
        ['Table','Rule','Smiley'],
        '/',
        ['FontName','FontFormat','FontSize'],
        ['Link','Unlink'],
        ['Source','Preview'],
        ['FitWindow','ShowBlocks','-','About']          // No comma for the last row.
] ;

FCKConfig.ToolbarSets["Light"] = [
        ['Undo','Redo'],
        ['Bold','Italic','Underline','StrikeThrough','RemoveFormat'],
        ['TextColor','BGColor','Smiley'],
        '/',
        ['FontName','FontFormat','FontSize']           // No comma for the last row.
] ;

FCKConfig.LinkBrowser = false ;
FCKConfig.ImageBrowser = false ;
FCKConfig.FlashBrowser = false ;
FCKConfig.LinkUpload = false ;
FCKConfig.ImageUpload = false ;
FCKConfig.FlashUpload = false ;

FCKConfig.FontNames             = "'ＭＳ Ｐゴシック';'ＭＳ Ｐ明朝';'ＭＳ ゴシック';'ＭＳ 明朝';MS UI Gothic;Arial;Comic Sans MS;Courier New;Tahoma;Times New Roman;Verdana" ;

