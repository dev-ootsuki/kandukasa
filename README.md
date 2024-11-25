# Kandukasa

## 動かし方 (development)
```project root
docker compose build
docker compose --profile db --profile auth up
```
初回起動はfrontendのnode_modules、backendのvendor/bundleの両方を落としてくるので起動は遅いです。

## 動かし方 (production)

docker-compose.yml.prod
を見てビルド（後でビルドスクリプトを書く）

## 動かし方 (コンテナ以外)

あとでinstall.shを書く