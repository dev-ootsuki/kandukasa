#!/bin/sh
CN=$1
PP=$2
DIR=$3
# 対話式で入力するdistinguished nameを一度に指定。コモンネームは第1引数
SJ="/C=JP/ST=Tokyo/L=Chuou-ku/O=$LDAP_DOMAIN/OU=$LDAP_DOMAIN/CN=$CN"
 
cd $3
# 秘密鍵を作成
openssl genrsa -des3 -passout pass:$PP -out $CN.key 2048 
# パスフレーズなしの秘密鍵にする
openssl rsa -passin pass:$PP -in $CN.key -out $CN.key
# CSR出力
openssl req -new -sha256 -key $CN.key -out $CN.csr -subj "$SJ" 
# crt
openssl x509 -days 365 -req -signkey $CN.key -in $CN.csr -out $CN.crt
# pem
cat $CN.key $CN.crt > $CN.pem