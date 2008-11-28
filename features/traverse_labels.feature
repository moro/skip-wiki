フィーチャ: ラベルをたどる
  ラベルの付いたページや、付いていないページをそれぞれ辿れるようにしたい

  シナリオ: ラベルなしページを表示し、1つ進める
    前提 言語は"ja-JP"
    かつ デフォルトのカテゴリが登録されている
    かつ ユーザ"alice"を登録する
    かつ ユーザのIdentity URLを"http://nimloth.local:3333/user/alice"として登録する
    かつ OpenId "http://nimloth.local:3333/user/alice"でログインする
    かつ ノート"a_note"が作成済みである
    かつ そのノートにはページ"page_0"が作成済みである
    かつ そのノートにはページ"page_1"が作成済みである

    もし ノート"a_note"のページ"page_0"を表示している
    ならば "page_0"と表示されていること

    もし "進む"リンクをクリックする
    かつ 再読み込みする
    ならば "page_1"と表示されていること

    もし "戻る"リンクをクリックする
    かつ 再読み込みする
    ならば "page_0"と表示されていること
