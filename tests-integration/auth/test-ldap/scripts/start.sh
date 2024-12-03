#!/bin/sh
echo "###############################################"
echo "# start slapd server."
echo "###############################################"
mkdir -p /container/service/slapd/assets/config/bootstrap/schema/custom
/container/tool/run &

echo "###############################################"
echo "# wait ldaps://$LDAP_DOMAIN (60s)"
echo "###############################################"
sleep 5
dockerize -wait tcp://test-ldap:389 -timeout 60s
echo "###############################################"
echo "# set initial ldap users."
echo "###############################################"
ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f $LDAP_DATA_PATH/slapd.d/ldif/acl.ldif
ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f $LDAP_DATA_PATH/slapd.d/ldif/olc.ldif
/usr/local/bin/set_ldapuser.sh
tail -f /dev/stdout