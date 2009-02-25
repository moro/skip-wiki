フィーチャ: セッション管理
  利用者として
  ユーザ登録とログインをしたい

  シナリオ: サインアップ
    前提 I log in with OpenId "http://localhost:3200/user/moro"

    もし I fill in "User|Name" with "moro"
    かつ I fill in "User|Display Name" with "A User Human Name"
    かつ I press "Sign up"

    ならば I should see "Thanks for signing up!"
    かつ   "Login ID: moro"と表示されていること

  シナリオ: ログイン
    前提   言語は"ja-JP"
    かつ   ユーザ"alice"を登録する
    かつ   ユーザのIdentity URLを"http://localhost:3200/user/alice"として登録する
    もし   OpenId "http://localhost:3200/user/alice"でログインする
    ならば I should not see "Thanks for signing up!"

    もし    再読み込みする
    ならば  "ログインID: alice"と表示されていること

  シナリオ: ログアウト
    前提シナリオ: ログイン
    もし   "ログアウト"リンクをクリックする
    かつ   "再読み込みする"
    ならば "OpenIDでログインできます"と表示されていること
    かつ   "ログインID: alice"と表示されていないこと

  シナリオ: ログイン失敗
    前提   言語は"ja-JP"
    もし   OpenId "http://localhost:3200/user/alice"でログイン失敗する
    かつ   "再読み込みする"

    ならば "OpenIDでログインできます"と表示されていること
    かつ   "ログインID: alice"と表示されていないこと

