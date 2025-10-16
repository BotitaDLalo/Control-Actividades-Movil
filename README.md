# aprende_mas
Ejecuta:

flutter pub get
# Comandos para generar archivo.jks

https://docs.flutter.dev/deployment/android

keytool -genkey -v -keystore d:\login-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias login-keystore


keytool -importkeystore -srckeystore d:\login-keystore.jks -destkeystore d:\login-keystore.jks -deststoretype pkcs12

comando para obtener SHA-1 y SHA-256:
cd Android
./gradlew signingReport

hola221