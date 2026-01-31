# Comandos de linux

Los comandos en este archivo son útiles para la materia de Desarrollo en la nube.

## SSH

Secure Shell (SSH)

Comando para conectar a un servidor remoto vía SSH:

```bash
ssh usuario@direccion_ip -i /ruta/a/tu/llave_privada.pem
```

La llave privada debe tener permisos restrictivos:

```bash
chmod 400 /ruta/a/tu/llave_privada.pem
```
Puedes verificar los permisos con:

```bash
ls -l /ruta/a/tu/llave_privada.pem
## Salida esperada: -r-------- 1 usuario usuario 1692 Mar 10 12:34 /ruta/a/tu/llave_privada.pem
```

## SCP

Secure Copy Protocol (SCP)

Comando para copiar archivos entre tu máquina local y un servidor remoto:

```bash
scp -i /ruta/a/tu/llave_privada.pem /ruta/al/archivo_local usuario@direccion_ip:/ruta/de/destino_remoto
```
O para copiar desde el servidor remoto a tu máquina local:

```bash
scp -i /ruta/a/tu/llave_privada.pem usuario@direccion_ip:/ruta/al/archivo_remoto /ruta/de/destino_local
```
Para copiar directorios completos, usa la opción `-r`:

```bash
scp -r -i /ruta/a/tu/llave_privada.pem /ruta/al/directorio_local usuario@direccion_ip:/ruta/de/destino_remoto
```

## exit

Comando para salir de una sesión SSH:

```bash
exit
```
