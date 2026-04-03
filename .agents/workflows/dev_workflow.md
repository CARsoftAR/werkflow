---
description: Siempre compilar y generar APK tras un cambio
---

Este flujo de trabajo DEBE seguirse después de cada modificación del código:

1. Realizar los cambios solicitados en el código de Flutter.
2. Ejecutar la compilación del APK en modo release.
// turbo
3. Comando: `flutter build apk --release`
4. Copiar el APK a la raíz: `cp build\app\outputs\flutter-apk\app-release.apk WerkFlow.apk`
5. Confirmar que el archivo `WerkFlow.apk` se ha generado correctamente en la raíz.
