#####
SAN=DNS:localhost \
openssl req -new \
    -config etc/server.conf \
    -out certs/localhost.csr \
    -keyout certs/localhost.key \
	-batch \
	-passout pass:changeit 


openssl ca \
    -config etc/saly-signing-ca.conf \
    -in certs/localhost.csr \
    -out certs/localhost.crt \
    -extensions server_ext \
	-batch \
	-passin pass:changeit
	
echo tls server certificate ok
	
openssl req -new \
    -config etc/client.conf \
    -out certs/hnelsonclient.csr \
    -keyout certs/hnelsonclient.key \
    -batch \
	-passout pass:changeit
	
openssl ca \
    -config etc/saly-signing-ca.conf \
    -in certs/hnelsonclient.csr \
    -out certs/hnelsonclient.crt \
    -batch \
	-passin pass:changeit \
	-extensions client_ext

echo tls client certificate ok

openssl pkcs12 -export \
    -name "hnelsonclient" \
    -inkey certs/hnelsonclient.key \
    -in certs/hnelsonclient.crt \
    -out certs/hnelsonclient.p12 \
	-passin pass:changeit \
	-passout pass:changeit


echo pkcs12 client certificate ok
	
openssl pkcs12 -export \
    -name "localhost" \
    -inkey certs/localhost.key \
    -in certs/localhost.crt \
    -out certs/localhost.p12 \
	-passin pass:changeit \
 -passout pass:changeit
 
#openssl x509 -in certs/hnelsonclient.crt -out certs/hnelsonclient.der -outform DER
#openssl x509 -in certs/localhost.crt -out certs/localhost.der -outform DER

#penssl x509 -inform der -outform PEM -in certs/hnelsonclient.der -out certs/hnelsonclient.pem
#openssl x509 -inform der -outform PEM -in certs/localhost.der -out certs/localhost.pem

#cat certs/hnelsonclient.pem ca/chain-ca.pem > certs/truststorecerts.pem

 #http://openssl.6102.n7.nabble.com/FWD-Intermediate-certificate-chain-not-included-when-exporting-as-pkcs12-td11892.html
 openssl pkcs12 -export \
    -inkey certs/localhost.key \
    -in certs/localhost.crt \
    -out certs/localhost_tc.p12 \
	-passin pass:changeit \
	-name "tomcat" \
	-CAfile ca/chain-ca.pem \
	-chain \
	-passout pass:changeit 
	
rm certs/truststore.jks	
	
"$JAVA_HOME/bin/keytool" -import -v  -file certs/hnelsonclient.crt -keystore certs/truststore.jks  -storepass changeit -noprompt
"$JAVA_HOME/bin/keytool" -import -v  -file ca/root-ca.crt -keystore certs/truststore.jks  -storepass changeit -noprompt -alias root-ca
"$JAVA_HOME/bin/keytool" -import -v  -file ca/signing-ca.crt -keystore certs/truststore.jks  -storepass changeit -noprompt -alias sig-ca
echo fin

	
	