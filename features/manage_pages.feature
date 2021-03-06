フィーチャ: ページ管理
  ログインしたユーザは自分たちが使うページを作成できるようにしたい

  シナリオ: ページ作成
    前提   言語は"ja-JP"
    かつ   ユーザ"alice"を登録し、ログインする
    かつ   ノート"a_note"が作成済みである
    かつ   そのノートにはラベル"Labelindice"が作成済みである
    かつ   ノート"a_note"のページ"FrontPage"を表示している

    もし "ページを追加"リンクをクリックする
    ならば "新しいページを作る"と表示されていること

    もし "ページ名"に"ページ「い」"と入力する
    かつ "ページ識別子"に"page_1"と入力する
    かつ "内容"に"これはテストページです"と入力する
    かつ "Labelindice"を選択する
    かつ "作成"ボタンをクリックする
    かつ 再読み込みする

    ならば "ページ「い」"と表示されていること
    かつ   "これはテストページです"と表示されていること
    かつ   "Labelindice"と表示されていること
    かつ   "ページを編集"と表示されていること

    もし "ページ一覧"リンクをクリックする
    ならば "ページ「い」"と表示されていること
    かつ   "履歴を表示"と表示されていること

  シナリオ: ページの一覧
    前提   言語は"ja-JP"
    かつ   ユーザ"alice"を登録し、ログインする
    かつ   ノート"a_note"が作成済みである
    かつ   そのノートにはラベル"Labelindice"が作成済みである
    かつ   ユーザ"bob"を登録し、ログインする
    かつ   そのノートにはページ"SecondPage"が作成済みである
    かつ   そのページはラベル"Labelindice"と関連付けられている
    かつ   OpenId "http://localhost:3333/user/alice"でログインする
    かつ   ノート"a_note"のページ"FrontPage"を表示している

    もし   "ページ一覧"リンクをクリックする
    ならば "FrontPage"と表示されていること
    かつ   "SecondPage"と表示されていること

    もし   "ページ内のキーワード"に"SKIP Noteへようこそ"と入力する
    かつ   "絞り込み"ボタンをクリックする
    ならば "FrontPage"と表示されていること
    かつ   "SecondPage"と表示されていないこと

    もし   "ページ内のキーワード"に""と入力する
    かつ   "最終更新者"に"alice"と入力する
    かつ   "絞り込み"ボタンをクリックする
    ならば "FrontPage"と表示されていること
    かつ   "SecondPage"と表示されていないこと

    もし   "ページ内のキーワード"に"SKIP Noteへようこそ"と入力する
    かつ   "最終更新者"に"bob"と入力する
    かつ   "絞り込み"ボタンをクリックする
    ならば "FrontPage"と表示されていないこと
    かつ   "SecondPage"と表示されていないこと

    もし   "ページ内のキーワード"に""と入力する
    かつ   "最終更新者"に""と入力する
    かつ   "ラベル識別子"から"No Labels"を選択する
    かつ   "絞り込み"ボタンをクリックする
    ならば "FrontPage"と表示されていること
    かつ   "SecondPage"と表示されていないこと

  シナリオ: ページの編集
    前提 言語は"ja-JP"
    かつ ユーザ"alice"を登録し、ログインする
    かつ ノート"a_note"が作成済みである
    かつ ノート"a_note"のページ"FrontPage"を表示している

    もし "プロパティを編集"リンクをクリックする
    かつ "ページ識別子"に"FroooooooooontPage"と入力する
    かつ "更新"ボタンをクリックする
    ならば "エラーが発生しました"と表示されていること

    もし "ページ名"に"かつて表紙だったページ"と入力する
    かつ "ページ識別子"に"FrontPage"と入力する
    かつ "公開日時"に"2008-12-01"と入力する
    かつ "更新"ボタンをクリックする
    かつ 再読み込みする

    ならば "かつて表紙だったページ"と表示されていること
    かつ "SKIP Noteへようこそ"と表示されていること

    もし "ページを編集"リンクをクリックする
    かつ "内容"に"これはテストページです"と入力する
    かつ "更新"ボタンをクリックする
    かつ 再読み込みする

    ならば "これはテストページです"と表示されていること

  シナリオ: ページの履歴閲覧
  前提シナリオ: ページの編集
    前提 ノート"a_note"のページ"FrontPage"を表示している
    もし "編集履歴"リンクをクリックする
    ならば "「かつて表紙だったページ」の編集履歴"と表示されていること

    もし テーブル"histories"の"1"行目の"前"リンクをクリックする
    ならば "リビジョン1の内容"と表示されていること
    かつ   "SKIP Noteへようこそ"と表示されていること
    かつ   "<h1>SKIP Noteへようこそ</h1>"と表示されていること
    かつ   "リビジョン2の内容"と表示されていること
    かつ   "これはテストページです"と表示されていること

    もし "履歴一覧に戻る"リンクをクリックする
    ならば "「かつて表紙だったページ」の編集履歴"と表示されていること

    もし "rev.1を表示"リンクをクリックする
    ならば "SKIP Noteへようこそ"と表示されていること
    かつ "rev.1"と表示されていること
    かつ "alice"と表示されていること

  シナリオ: ページ作成に失敗
    前提   言語は"ja-JP"
    かつ ユーザ"alice"を登録し、ログインする
    かつ   ノート"a_note"が作成済みである
    かつ   ノート"a_note"のページ"FrontPage"を表示している

    もし "ページを追加"リンクをクリックする
    ならば "新しいページを作る"と表示されていること

    もし "ページ名"に"ページ「い」"と入力する
    かつ "内容"に"これはテストページです"と入力する
    かつ "作成"ボタンをクリックする

    ならば "新しいページを作る"と表示されていること
    かつ   "ページにエラーが発生しました。"と表示されていること

