フィーチャ: セッション管理
  ログイン状態や権限を管理するため、ユーザの登録とログインができるようにしたい。

  シナリオ: サインアップ
    前提 I log in with OpenId "http://nimloth.local:3333/user/moro"

    もし I fill in "account[login]" with "moro"
    かつ I fill in "account[email]" with "moro@example.com"
    かつ I press "Sign up"

    ならば I should see "Thanks for signing up!"
    かつ   I should see "Your profile(moro)"

  シナリオ: ログイン
    前提   ユーザ"alice"を登録する
    かつ   ユーザのIdentity URLを"http://nimloth.local:3333/user/alice"として登録する
    もし   OpenId "http://nimloth.local:3333/user/alice"でログインする
    ならば I should not see "Thanks for signing up!"
    かつ   I should see "Your profile(alice)"

