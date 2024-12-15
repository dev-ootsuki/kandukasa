# Kandukasa

## 動かし方 (production)
```project root
docker compose build
docker compose --profile mysql up
```
初回起動はfrontendのnode_modules、backendのvendor/bundleの両方を落としてくるので起動は遅いです。

起動後に

https://localhost/

にアクセスして右上の歯車を押下してDB接続先設定を選択、コンテナ上から接続可能なDBへの接続を設定してご利用ください！

docker-compose.ymlを使って試す場合は

・製品：MySQL

・ホスト： test-mysql

・ポート： 3306

・デフォルトスキーマ：sakila か world

・ユーザ： root

・パスワード： test

が利用できます。

もしくはコンテナから到達可能な接続先としてご自由に設定して下さい！

また、このtest-mysqlを元に戻したい場合は

・docker volume rm でボリュームを消して再度upする

・docker compose exec test-mysql bash

でログインして 

/docker-entrypoint-initdb.d にある02_restore_db.shを参考にリストア

してください！

## 動かし方 (development)
``` project root
docker compose -f compose-dev.yml build
docker compose -f compose-dev.yml --profile mysql up
```

## 動かし方 (コンテナ以外)

あとでinstall.shを書く

## やる事リスト(backend)

* rdocとしてbackendのコードにコメントを書く
* 複数DB製品を考慮してMySQLコードから共通化してAuto以下に移動する
* 特殊な型＠binary/varbinary/geometry/blob系は手厚くテストする必要がある
* テストコードちゃんと書いてく、できれば複数DB製品対応前にMySQL分は完備したい
* 日付のフォーマットでDBのタイムゾーン見てコンテナのタイムゾーンに合わせて返すようにする
* logが出しっぱなしなのでローテートは入れておきたい
* できればopenapi(swagger)も書く、ruby/railsでいいのないか探す
* 訳が分からないような処理はコメント書いてく！
* TODO書いてるところを直していく！！！！
* ${PROJECT_ROOT}/backend/README.mdにディレクトリ構造と内容を書く
* production / developmentのGemfile.lock分けるか本番用だけtest:developmentが必要としないようにどっかでbundle config書く必要がある、今はbundle installしてるので辞めたい

## やる事リスト(frontend)

* jsdocちゃんと書く
* style.cssに全部寄せしてるの直す
* middlewaresが動かない問題はnuxtがserverモードじゃないとダメなのか調べる
* decoratorsがエラーになるやつ、nuxt対応するにはどうするのがベストか調べる
* lint入ってないので入れる
* frontendでどこまで自動テストコードを書くか決める
* DbConnectionsStore.tsが肥大化しつつあるのを分割したい
* DBデータ検索とかでHACK的にref<InstanceType<typeof Xxxx>>()がとれない問題解決しているのをvueの流儀に則りたい
* ${PROJECT_ROOT}/frontend/README.mdにディレクトリ構造と内容を書く
* validate errorになったやつを画面に反映させるかdialog出す

## やる事リスト(infra)

* production用のビルドスクリプト書く
* dockerhubに登録して別プロジェクトで簡単に使えるようにしたい
* 外から環境変数でタイムゾーンを設定できるようにする
* ベースイメージをpostgresql:17.2-alpineにしたい
* compose使わないでproductionを普通にイメージにする用のbash書く
* github actionsのcheckout@v3がv4出てるらしいので調べる

## 作りたい機能リスト（未実装リスト）

* ログインユーザー
* ユーザーの権限
* 認証
* 認証の外部連携（SAML・LDAP）
* SQL保存は全体か個人かは欲しい、権限別もあると良い？どうデータもつか検討する、SQL実行時にパラメータを指定できるようにしたい（？複数をinputでバインドしてbackendに投げる）
* google spread sheetにデータを反映/読み込みする時用に外部連携機能でトークン持っておきたい
* アプリケーション全体設定（スタンドアロンか、認証ありか、どの認証か、デザイン設定を個人で更に上書きできるか、対応製品設定、とか）
* DB接続時の認証方法は増やしたい（SSL/AWS IAMでSecretsManager経由とか）
* 定点観測したい、SQL保存のを使うのか、使うならSQL保存のデータの持ち方とか
* sidekiqで定点観測する仕組みが必要
* テーブル詳細のところでデータと定義自体をクリップボードコピー、text(csv)、text(sql dump)、excel、google spred sheetへexport/importは欲しい
* テーブル一覧のところで詳細と同じ機能は欲しい
* スキーマのところでテーブル一覧とか詳細と同じ感じ
* デザイン設定をID/jsonで登録しておいてユーザー自体にどのデザイン使うかを設定したい
* ダッシュボード登録すればホームにダッシュボードで指定したSQL実行結果or定点観測結果を表示できるようにしたい
* SQL自由入力で補完が効くようにしたいけど補完なしで早めに作るべき？
* postgresqlとsqlserverは対応したい、できればoracleも
* noSQL対応したいけど、どの程度の構成情報がとれるか調べてから決める
* テーブル全体の構造をfkeyを元にツリー構造にした情報をbackendでまとめたい
* 上記をcanvasにしてカラム名最大文字数(横) * (カラム数 + indexesラベル分 + indexes数 + FKEYラベル + FKEY数 + PKEYラベル + PKEY数）(縦)で計算して1:1:N:M見たいのを縦にグループで並べつつ別項目は横に並べてER図を出したい
* ER図をそのままスキーマに投入するかcreate table文をテキストかダウンロードできるようにする
* テーブル別に実行計画叩けるようにしたい
* 統計情報としてsysスキーマから抜き出してテーブルとかDBサーバー情報をもっと充実させる！！
* 左メニューに保存したSQL一覧出して別機能として表示させたい

## 実装中/とりあえずこれから実装

* カラム更新・新規登録、できればテーブル新規作成時に使いまわしたい
* 特殊なデータ型のデータに対応
* テーブル詳細にFKEY/indexesは追加・更新・削除欲しい
* テーブル新規作成
* スキーマ削除
* スキーマ権限を見てボタン表示制御＠どうやって複数製品の権限を一元化するかは検証する必要あり
* SQL実行と結果表示
* trigger/routine/event/viewの一覧表示、登録・更新・削除
* DB接続登録時にテストボタンは欲しい
