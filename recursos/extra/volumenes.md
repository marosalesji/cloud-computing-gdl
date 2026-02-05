# Manejo de Volúmenes y Sistemas de Archivos en Linux

```bash
# Ver el uso del disco
du -h --max-depth=1

# Ver el espacio libre en disco
df -h

# crear un file system
sudo mkfs -t ext3 /dev/sdX

# montar un file system
sudo mount /dev/sdX /mnt/punto_de_montaje

# desmontar un file system
sudo umount /mnt/punto_de_montaje
```
