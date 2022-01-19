#!/bin/bash
base=`cat cert-base.cnf`
baseExt=`cat cert-base.ext`
domain=$1
COUNTRY="US"
STATE="CA"
LOCALITY="CA"
OCCUPATION="IT"
OCCUPATION_UNIT="IT"
base="${base/__COUNTRY__/"$COUNTRY"}"
base="${base/__STATE__/"$STATE"}"
base="${base/__LOCALITY__/"$LOCALITY"}"
base="${base/__OCCUPATION__/"$OCCUPATION"}"
base="${base/__OCCUPATION_UNIT__/"$OCCUPATION_UNIT"}"
base="${base//__DOMAIN__/"$domain"}"
baseExt="${baseExt//__DOMAIN__/"$domain"}"
extFilename="certs/${domain}.ext"
cnfFilename="certs/${domain}.cnf"
echo "$base">"$cnfFilename"
echo "$baseExt">"$extFilename"
echo "Generating cert for ${domain}"
keyFilePath="/etc/apache2/conf/ssl/${domain}.key"
openssl ecparam -name prime256v1 -genkey -noout -out $keyFilePath
openssl req -new -sha256 -key "/etc/apache2/conf/ssl/${domain}.key" -out "/etc/apache2/conf/ssl/${domain}.csr" -config "certs/${domain}.cnf"
openssl x509 -req -in "/etc/apache2/conf/ssl/${domain}.csr" -CA /etc/ssl/certs/ca-development.pem -CAkey /etc/ssl/certs/ca-development.key -CAcreateserial -out "/etc/apache2/conf/ssl/${domain}.crt" -days 825 -sha256 -extfile "certs/${domain}.ext"
