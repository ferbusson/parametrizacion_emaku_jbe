#!/bin/bash

USER="emaku"
PGPASSWORD=control
export PGPASSWORD
DB_HOST="localhost"
DB_NAME="xtremen"

#Actualiza inventarios de pedidos vencidos
        
            query="SELECT control_vencimiento_pedidos();"
            echo $query | psql -U $USER -h $DB_HOST -d $DB_NAME
