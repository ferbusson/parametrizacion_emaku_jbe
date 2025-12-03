# Manual de Regeneración de Certificado para Facturación Electrónica

## Descripción General

Este manual describe el procedimiento para regenerar el certificado digital requerido por la plataforma de facturación electrónica, convirtiendo los archivos `.key` y `.pem` en un archivo `.p12` compatible.

---

## Requisitos Previos

### Archivos necesarios:
- `Facturación Electrónica - JAVIER BENAVIDES ERAZO SAS.pem` (certificado)
- `private.key` (clave privada)

### Credenciales:
- **Password:** NIT de la empresa sin dígito de verificación ni guiones

---

## Procedimiento

### 1. Subir Archivos al Servidor

Cargar los archivos al directorio home del usuario en el servidor (ejemplo: usuario `jbe`).

### 2. Renombrar Archivo PEM

Para facilitar la ejecución del comando, renombrar el archivo `.pem`:

```bash
mv "Facturación Electrónica - JAVIER BENAVIDES ERAZO SAS.pem" facturacionElectronicaJavierBenavidesErazoSAS.pem
```

### 3. Generar Archivo .p12

Ejecutar el siguiente comando para generar el certificado:

```bash
openssl pkcs12 -export -inkey private.key -in facturacionElectronicaJavierBenavidesErazoSAS.pem -name "mi_certificado" -out certificado_2025.p12 -keypbe PBE-SHA1-3DES -certpbe PBE-SHA1-3DES -legacy
```

**Nota:** El sistema solicitará ingresar y confirmar el password (NIT sin dígito de verificación ni guiones).

El archivo `certificado_2025.p12` se generará en el mismo directorio donde se ejecutó el comando.

### 4. Mover Certificado al Directorio de Emaku

Copiar el archivo `.p12` al directorio de certificados de Emaku:

```bash
cp certificado_2025.p12 /home/emaku/certs/
```

Si el directorio no existe, crearlo:

```bash
mkdir -p /home/emaku/certs
```

### 5. Configurar Permisos

Asignar los permisos adecuados al directorio y archivos:

```bash
chown -R emaku:emaku /home/emaku/certs
```

### 6. Actualizar Configuración de Emaku

Editar el archivo de configuración de Emaku:

```bash
nano /usr/local/emaku/conf/emaku.conf
```

Configurar el nombre del certificado generado y la contraseña correspondiente.

### 7. Reiniciar Servicio

Reiniciar el servicio de Emaku para aplicar los cambios:

```bash
/etc/init.d/emaku stop;/etc/init.d/emaku start
```

---

## Comando Alternativo

En algunos casos se puede utilizar este comando alternativo para la regeneración:

```bash
openssl pkcs12 -export -out certificado_2025.p12 -inkey private.key -in ARCHIVO_CRT.crt
```

---

## Verificación

Para verificar que el archivo `.p12` se generó correctamente:

```bash
keytool -list -v -storetype pkcs12 -keystore certificado_2025.p12
```

Este comando mostrará la información detallada del certificado almacenado.