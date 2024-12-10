# Kandukasa

## 動かし方 (development)
```project root
docker compose build
docker compose --profile db --profile auth up
```
初回起動はfrontendのnode_modules、backendのvendor/bundleの両方を落としてくるので起動は遅いです。

起動後に

https://localhost/

にアクセスして右上の歯車を押下してDB接続先設定を選択、コンテナ上から接続可能なDBへの接続を設定してご利用ください！

docker-compose.ymlを使って試す場合は

・製品：MySQL

・ホスト： test-mysql

・ポート： 3306

・ユーザ： root

・パスワード： test

が利用できます。

また、このtest-mysqlを元に戻したい場合は

・docker volume rm でボリュームを消す

・docker compose exec test-mysql bash

でログインして 

/docker-entrypoint-initdb.d にある02_restore_db.shを参考にリストア

してください！

## 動かし方 (production)

docker-compose.yml.prod
を見てビルド（後でビルドスクリプトを書く）

## 動かし方 (コンテナ以外)

あとでinstall.shを書く