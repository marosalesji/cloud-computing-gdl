# Product Catalog

Este demo crea una tabla de dynamodb llamada ProductCatalog con una particion llamada 'nombre',
y muestra como interacturar con la tabla utilizando AWS CLI.

## Requisitos

El sandbox de AWS Cloud Foundations no tiene acceso a DynamoDB, por lo que es necesario usar
AWS Learner Lab.

## Crear la tabla DynamoDB

Verificar si la tabla ya existe:

```bash
export REGION=us-east-1
aws dynamodb describe-table --table-name ProductCatalog --region $REGION
```

Crear la tabla

```bash
aws dynamodb create-table \
  --table-name ProductCatalog \
  --attribute-definitions \
    AttributeName=producto_id,AttributeType=S \
  --key-schema \
    AttributeName=producto_id,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region $REGION
echo "Tabla ProductCatalog creada"
```

Notas:
- `producto_id` es el nombre del atributo que se usará como clave de partición (HASH key) para la tabla.

Vamos a listar las tablas para confirmar:

```bash
aws dynamodb list-tables --region $REGION
```

## Usar AWS CLI para insertar productos

```bash
# Agregar productos
aws dynamodb batch-write-item --request-items file://productos-01.json

# Ver todos los elementos
aws dynamodb scan \
  --table-name ProductCatalog \
  --region us-east-1

# Filtrar por producto_id
aws dynamodb query \
  --table-name ProductCatalog \
  --key-condition-expression "producto_id = :pid" \
  --expression-attribute-values '{
    ":pid": { "S": "PROD-003" }
  }' \
  --region us-east-1

# Agregar mas productos
aws dynamodb batch-write-item --request-items file://productos-02.json
```


## Eliminar la tabla

```bash
aws dynamodb delete-table \
  --table-name ProductCatalog \
  --region $REGION
```
