#!/bin/bash
yum install compat-openldap openldap-clients openldap-servers nss-pam-ldapd -y
systemctl start slapd
systemctl enable slapd
cd ldifs
PW=$(slappasswd -s 1234 -n)
sed "s/olcRootPW:.*/olcRootPW: $PW/g" -i dbinit.ldif
ldapmodify -Y EXTERNAL -H ldapi:/// -f dbinit.ldif
ldapmodify -Y EXTERNAL -H ldapi:/// -f monitor.ldif
cp dadcorp.* /etc/openldap/certs/
ldapmodify -Y EXTERNAL -H ldapi:/// -f key.ldif
ldapmodify -Y EXTERNAL -H ldapi:/// -f pem.ldif
slaptest -u

ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif

#Add OU
ldapadd -x -w 1234 -D cn=ldapadm,dc=dadcorp,dc=com -f base.ldif
#ADD User
ldapadd -x -w 1234 -D cn=ldapadm,dc=dadcorp,dc=com -f users.ldif
#Verify
ldapsearch -h localhost -D cn=ldapadm,dc=dadcorp,dc=com -w 1234 -b dc=dadcorp,dc=com "uid=bbanner"

#Change Pass
# ldappasswd -x -w 1234 -D cn=ldapadm,dc=dadcorp,dc=com -h localhost -S uid=tstark,ou=People,ou=Sales,dc=dadcorp,dc=com