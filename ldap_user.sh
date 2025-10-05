#!/bin/bash

source .env

# Deriva il DN dal dominio
BASE_DN=$(echo $LDAP_DOMAIN | sed 's/\./,dc=/g' | sed 's/^/dc=/')
ADMIN_DN="cn=admin,${BASE_DN}"

# --- Funzione per eseguire comandi LDAP ---
run_ldap_command() {
  docker compose exec -e BASE_DN=${BASE_DN} -T openldap ldapadd -x -w "${LDAP_ADMIN_PASSWORD}" -D "${ADMIN_DN}"
}

echo ">>> Creazione delle Unità Organizzative (OU)..."
run_ldap_command << EOF
# OU per gli utenti
dn: ou=devops,${BASE_DN}
objectClass: organizationalUnit
ou: devops

# OU per i gruppi
dn: ou=developer,${BASE_DN}
objectClass: organizationalUnit
ou: developer
EOF

echo ">>> Creazione degli Utenti..."
run_ldap_command << EOF
# Utente: fdimarco
dn: uid=fdimarco,ou=devops,${BASE_DN}
objectClass: top
objectClass: person
objectClass: inetOrgPerson
givenName: Filippo
sn: Di Marco
cn: Filippo Di Marco
uid: fdimarco
userPassword: password@123
mail: fdimarco@${LDAP_DOMAIN}

# Utente: lmaggio
dn: uid=lmaggio,ou=devops,${BASE_DN}
objectClass: top
objectClass: person
objectClass: inetOrgPerson
givenName: Luca
sn: Maggio
cn: Luca Maggio
uid: lmaggio
userPassword: password@123
mail: lmaggio@${LDAP_DOMAIN}

# Utente: lmaggio
dn: uid=mrossi,ou=developer,${BASE_DN}
objectClass: top
objectClass: person
objectClass: inetOrgPerson
givenName: Mario
sn: Rossi
uid: mrossi
cn: Mario Rossi
userPassword: password@123
mail: mrossi@${LDAP_DOMAIN}
EOF

echo ">>> Creazione dei Gruppi e Aggiunta Membri..."
run_ldap_command << EOF
# Gruppo: appdev-team
dn: cn=appdev-team,ou=developer,${BASE_DN}
objectClass: top
objectClass: groupOfNames
cn: appdev-team
description: App Development Team
member: uid=mrossi,ou=people,${BASE_DN}

# Gruppo: devops-team
dn: cn=devops-team,ou=devops,${BASE_DN}
objectClass: top
objectClass: groupOfNames
cn: devops-team
description: DevOps Team (Gitea Admins)
member: uid=fdimarco,ou=devops,${BASE_DN}
member: uid=lmaggio,ou=devops,${BASE_DN}
EOF

echo ">>> Script completato."