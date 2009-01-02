フィーチャ: セッション管理
  ログイン状態や権限を管理するため、ユーザの登録とログインができるようにしたい。

  シナリオ: サインアップ
    前提 I log in with OpenId "http://localhost:3200/user/moro"

    もし I fill in "Login" with "moro"
    かつ I fill in "Email" with "moro@example.com"
    かつ I press "Sign up"

    ならば I should see "Thanks for signing up!"
    かつ   I should see "Your profile(moro)"

  シナリオ: ログイン
    前提   言語は"ja-JP"
    かつ   ユーザ"alice"を登録する
    かつ   ユーザのIdentity URLを"http://localhost:3200/user/alice"として登録する
    もし   OpenId "http://localhost:3200/user/alice"でログインする
    ならば I should not see "Thanks for signing up!"

    もし    再読み込みする
    ならば  "プロフィール(aliceさん)"と表示されていること

  シナリオ: ログアウト
    前提シナリオ: ログイン
    もし   "ログアウト"リンクをクリックする
    かつ   "再読み込みする"
    ならば "OpenIDでログインできます"と表示されていること
    かつ   "プロフィール(aliceさん)"と表示されていないこと

  シナリオ: ログイン失敗
    前提   言語は"ja-JP"
    もし   OpenId "http://localhost:3200/user/alice"でログイン失敗する
    かつ   "再読み込みする"

    ならば "OpenIDでログインできます"と表示されていること
    かつ   "プロフィール(aliceさん)"と表示されていないこと

