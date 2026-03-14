# Permisos de archivos en sistemas Unix/Linux

Para ver los permisos de los archivos usamos el comando `ls -l` para hacer ls long listing.

```
$ ls -l
total 4
drwxr-xr-x. 1 marosalesji marosalesji 40 Feb  3 22:04 extra
-rw-r--r--. 1 marosalesji marosalesji 93 Feb  3 22:04 README.md
```

El primer elemento de la salida indica el tipo de archivo, `d` indica que es un directorio y `-` indica que es un archivo regular.

Luego vienen los permisos divididos en tres grupos de tres caracteres cada uno:
- El primer grupo de tres caracteres indica los permisos del propietario del archivo.
- El segundo grupo de tres caracteres indica los permisos del grupo al que pertenece el archivo.
- El tercer grupo de tres caracteres indica los permisos para otros usuarios.

Es útil pensar en el acrónimo UGO (User, Group, Others) para recordar el orden de los permisos.

Los permisos se representan con valores octales:
- `r` (read) tiene un valor de 4.
- `w` (write) tiene un valor de 2.
- `x` (execute) tiene un valor de 1.

Ejemplo de permisos:
- `rwx` (lectura, escritura y ejecución) tiene un valor de 7 (4+2+1). También se puede ver como `rwx` = 111 en binario, que es 7 en octal.
- `rw-` (lectura y escritura) tiene un valor de 6 (4+2+0). En binario es 110, que es 6 en octal.
- `r--` (solo lectura) tiene un valor de 4 (4+0+0). En binario es 100, que es 4 en octal.

Para cambiar los permisos de un archivo usamos el comando `chmod` seguido de los valores octales para cada grupo.
```
$ chmod 755 archivo.sh # Permisos rwxr-xr-x
```

## Referencias

- [Linux file permissions explained](https://www.redhat.com/en/blog/linux-file-permissions-explained)
