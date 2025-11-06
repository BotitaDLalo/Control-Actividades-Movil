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

DETALLES A RESOLVER. -
- El Login funciona sin validar el Token (cambiar esto para que valide el token
    importante para las notificaciones push de firebase)
- El metodo de verificar Email no bloquea al usuario si no se valida correctamente
    el email, esto debe cambiarse por que debe verificar el Email siempre.
- 