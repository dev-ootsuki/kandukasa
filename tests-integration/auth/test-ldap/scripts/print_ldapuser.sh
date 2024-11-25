#!/bin/sh
# $1 : base DN (ex: dc=ci-next-ldap)
# $2 : userName
# $3 : password
# $4 : email
# $5 : kandukasa_role (extended attr)
# $6 : kandukasa_id (extended attr)
# $7 : user_level (extended attr)
# $8 : group id

BASE_DN=$1
USERID=$2
#PASSWORD=$(slappasswd -s "$3")
PASSWORD=$3

echo "dn: uid=$USERID,$BASE_DN"
echo "uid: $USERID"
echo "cn: $USERID"
echo "sn: docker"
echo "objectClass: posixAccount"
echo "objectClass: top"
echo "objectClass: shadowAccount"
echo "objectClass: inetOrgPerson"
echo "objectClass: kandukasaUser"
echo "objectCategory: user"
echo "userPassword: $PASSWORD"
echo "shadowLastChange: 15862"
echo "shadowMin: 0"
echo "shadowMax: 99999"
echo "shadowWarning: 7"
echo "loginShell: /bin/bash"
echo "homeDirectory: /home/$USERID"
echo "mail: $4"
echo "kandukasaId: $5"
echo "uidNumber: $6"
echo "gidNumber: $7"