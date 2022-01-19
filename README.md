# Vhosts generator
This tool generates vhosts files for Apache 2 and also creates SSL certificates for each TLD.

### Requirements
```bash
apt install -y jq dkms 
```

### SSL Certificates
The SSL certificates are generated using a self signed CA certificate, to create one, follow this steps:
```bash
openssl ecparam -name prime256v1 -genkey -noout -out ca-development.key
```

Generate CRT file to import into Windows and PEM file for Ubuntu

```bash
openssl req -new -x509 -sha256 -key ca-development.key -out ca-development.crt
#GENERATE PEM file
openssl req -x509 -new -nodes -key ca-development.key -sha256 -days 1825 -out ca-development.pem
```

Once generated copy __ca-development.pem__ to __/etc/ssl/certs__
```bash
cp ca-development.pem /etc/ssl/certs
```
Then run ```sudo c_rehash```

## 2. Install multiple PHP versions
Install PHP 5.6 and PHP 7.2
```bash
sudo apt update
sudo apt install libapache2-mod-fcgid
sudo apt install software-properties-common
sudo add-apt-repository ppa:ondrej/php && sudo apt update
sudo apt install -y libapache2-mod-fcgid php5.6 php5.6-fpm php7.2 php7.2-fpm php5.6-mysql php7.2-mysql php5.6-curl php7.2-curl php5.6-mbstring nodejs php5.6-xml php5.6-dom
sudo a2enmod actions alias proxy_fcgi fcgid rewrite
sudo service apache2 restart
```

### Virtual Hosts
Copy __vhosts-sample.json__ to __vhosts.json__ 

Required parameters:

- __name__: name of the project/site
- __public_path__: the relative path to __webroot__ where the project is located. 
- __server_name__: the domain for the project.
- __tld__: Top level domain for the project. Required to configure the ssl certificate.

Optional parameters: 

- __php_version__: The PHP version you want to use. Default is '5.6'.
- __server_aliases__: Different server aliases you want to use. Example: ```['myalias.localhost.test']```

### Generate vhosts and certs
Run:
```bash
sudo vhost-generator.sh
```

This will:

- Generate de vhosts file and copy them to __/etc/apache2/sites-enabled__
- Generate the certs and copy them to __/etc/apache2/conf/ssl/__
- Restart apache2

### Generate certs 
If you only want to generate a ssl cert for a sigle TLD (for example localhost.test), you can run:
```bash
sudo generate-cert.sh localhost.test
```

### Update windows hosts file
Execute ```update-win-hosts.ps1``` to update windows hosts file with the vhosts configured.  
This will check if the windows hosts file has already the vhosts configured, if not it will be added.  
Each vhosts will be configured with the following IPV4: **127.0.0.1** and IPV6 **::1** mainly to be able to work with WSL2