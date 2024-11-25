#!/bin/bash

WORKDIR=$LDAP_DATA_PATH
cd $WORKDIR
USERID=`cat $WORKDIR/userid_counter`
GROUPID=5000

while read line
do
  if [ ! -z "$line" ]; then
    USER=($(echo "$line" | tr "," " "))
    # USER[0] : ID
    # USER[1] : Password
    # USER[2] : email
    # USER[3] : kandukasa user id
    
    # 既に登録済みなら登録しない
    EXISTS=`ldapsearch -b "uid=${USER[0]},dc=kandukasa-ldap" -D "cn=admin,dc=kandukasa-ldap" -w kandukasa | grep "${USER[2]}" | wc -l`
    
    if [ $EXISTS -eq 0 ]; then
      /usr/local/bin/print_ldapuser.sh 'dc=kandukasa-ldap' ${USER[0]} ${USER[1]} ${USER[2]} ${USER[3]} $USERID $GROUPID > $WORKDIR/${USER[0]}.ldif
      slapadd -l $WORKDIR/${USER[0]}.ldif
      USERID=$((++USERID))
    fi
  fi
done < $WORKDIR/user_list.txt

echo "$USERID" > $WORKDIR/userid_counter
