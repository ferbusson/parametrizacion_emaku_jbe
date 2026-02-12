# se hacen los siguientes reemplazos en todos los archivos de las plantillas de impresion

#Reemplazos en archivos de plantillas de impresion:
#Cada comando genera un archivo de respaldo con extension .bak

find . -type f -exec sed -i.bak 's/LA CALI S.A.S Nit. 800.220.247-8/JAVIER BENAVIDES ERAZO S.A.S. Nit. 891.224.230-2/g' {} +

find . -type f -exec sed -i.bak 's/LA CALI/JAVIER BENAVIDES ERAZO/g' {} +

find . -type f -exec sed -i.bak 's/La Cali Web/JAVIER BENAVIDES ERAZO WEB/g' {} +

find . -type f -exec sed -i.bak 's/La Cali/JAVIER BENAVIDES ERAZO WEB/g' {} +

find . -type f -exec sed -i.bak 's|ALMACEN PRINCIPAL / Carrera 21 No. 15-68 Centro|ALMACEN PRINCIPAL / CARRERA 19 NRO 18-27-41-53-45 CENTRO|g' {} +

find . -type f -exec sed -i.bak 's|Tel: 7219070 - 3218028591|Tel: 7213282 - 3122589821|g' {} +

find . -type f -exec sed -i.bak 's|www.lacalionline.com|secretaria@javierbenavideserazosas.com|g' {} +



#Al fintalizar eliminar los archivos de respaldo
find . -name "*.bak" -delete

