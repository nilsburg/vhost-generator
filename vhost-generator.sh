#!/bin/bash
BASEDIR=$(dirname "$BASH_SOURCE")
json=`cat vhosts.json`
baseConf=`cat vhost.conf`
defaultPHPVersion="5.6"
defaultPort="443"
basePath=$(jq -r '.webroot' <<< "$json")
echo "Generating vhosts..."
echo "">"vhosts.txt"
function replaceValues() {
	newConf="${newConf//__SERVER_NAME__/"$serverName"}"
	newConf="${newConf//__SERVER_ALIASES__/"$strAliases"}"
	newConf="${newConf//__PHP_VERSION__/"$phpVersion"}"
	newConf="${newConf//__PORT__/"$port"}"
	newConf="${newConf//__NAME__/"$name"}"
	newConf="${newConf//__DOCUMENT_ROOT__/"$path"}"
	newConf="${newConf//__TLD__/"$tld"}"
	
}
for row in $(echo "$json" | jq -r '.vhosts[] | @base64'); do
	_jq(){
		echo ${row} | base64 --decode | jq -r ${1}		
	}
	newConf="$baseConf"
	name=$(_jq '.name')
	path=$(_jq '.project_path')
	path="${basePath}${path}"
	serverName=$(_jq '.server_name')
	phpVersion=$(_jq '.php_version')
	port=$(_jq '.post')
	ssl=$(_jq '.ssl')
	serverAliases=$(_jq '.server_aliases')
	strAliases=""
	tld=$(_jq '.tld')
	if [ "$phpVersion" == "null" ]; then
		phpVersion=$defaultPHPVersion
	fi
	if [ "$port" == "null" ]; then
		port=$defaultPort
	fi
	if [ "$serverAliases" != "null" ]; then
		strAliases="ServerAlias "
		for aliasRow in $(echo "$serverAliases" | jq -r '.[]'); do
			alias=$(echo "${aliasRow}")
			echo "ALIAS: $alias"
			echo $alias>>"vhosts.txt"
			strAliases="${strAliases} ${alias}"
		done		
	fi
	replaceValues
	newConf="${newConf//__SSL_START__/""}"
	newConf="${newConf//__SSL_END__/""}"
	echo "$newConf">"vhosts/${name}-${port}.conf"
	bash generate-cert.sh "${tld}"
	newConf=$baseConf
	port='80'
	newConf="${newConf//"SSLEngine on"/""}"
	newConf="${newConf//"SSLVerifyDepth 1"/""}"
	newConf="${newConf//"SSLCertificateFile /etc/apache2/conf/ssl/__TLD__.crt"/""}"
	newConf="${newConf//"SSLCertificateKeyFile /etc/apache2/conf/ssl/__TLD__.key"/""}"
	newConf="${newConf//"SSLCACertificateFile /etc/ssl/certs/ca-development.pem"/""}"
	replaceValues
	echo "Generating VHOST for ${name} with TLD ${tld}"
	echo "$newConf">"vhosts/${name}-${port}.conf"
	echo $serverName>>"vhosts.txt"
done
HOSTS_DIR="$BASEDIR/vhosts/*.conf"
cp $HOSTS_DIR /etc/apache2/sites-enabled/
service apache2 restart
