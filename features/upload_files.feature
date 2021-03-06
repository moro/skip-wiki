フィーチャ: ファイルをアップロードする
  ユーザは、ノートやページにファイルをアップロードできるようにしたい

  シナリオ: ノートにファイルをアップロードする
    前提 言語は"ja-JP"
    かつ ユーザ"alice"を登録する
    かつ ユーザのIdentity URLを"http://nimloth.local:3333/user/alice"として登録する
    かつ OpenId "http://nimloth.local:3333/user/alice"でログインする
    かつ ノート"a_note"が作成済みである

    もし ノート"a_note"のページ"FrontPage"を表示している
    かつ "ノートの添付ファイル"リンクをクリックする
    かつ "ファイルを添付"としてファイル"spec/fixtures/data/at_small.png"を添付する
    かつ "ファイルの説明"に"user iconとかに使ってる画像です"と入力する
    かつ "アップロード"ボタンをクリックする
    かつ 再読み込みする

    ならば "ノートの添付ファイル一覧"と表示されていること
    かつ "user iconとかに使ってる画像です"と表示されていること

  シナリオ: ページにファイルをアップロードする
    前提 言語は"ja-JP"
    かつ ユーザ"alice"を登録する
    かつ ユーザのIdentity URLを"http://nimloth.local:3333/user/alice"として登録する
    かつ OpenId "http://nimloth.local:3333/user/alice"でログインする
    かつ ノート"a_note"が作成済みである

    もし ノート"a_note"のページ"FrontPage"を表示している
    かつ "ページの添付ファイル"リンクをクリックする
    かつ "ファイルを添付"としてファイル"spec/fixtures/data/at_small.png"を添付する
    かつ "ファイルの説明"に"user iconとかに使ってる画像です"と入力する
    かつ "アップロード"ボタンをクリックする
    かつ 再読み込みする

    ならば "ページの添付ファイル一覧"と表示されていること
    かつ "user iconとかに使ってる画像です"と表示されていること

