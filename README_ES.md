# Cadena de procesamiento para la generación de datos de actividad para el proceso REDD+ de Guinea Ecuatorial
El material de este repositorio ha sido desarrollado para ejecutarse dentro de SEPAL (https://sepal.io)

El objetivo de la cadena de procesamiento es desarrollar datos de actividad para el NREF de Guinea Ecuatorial

## Características del NREF
El NREF combina el 'mapa de deforestación y degradación forestal de 2004-14', que se desarrolló a partir del conjunto de datos de GFC, con las nuevas pérdidas forestales entre 2014-2018 también del conjunto de datos de GFC, para producir el nuevo 'mapa de deforestación y degradación de 20014-18'.

- Período de 2014-2018 (5 años)
- 30% de umbral de cobertura de dosel para la definición de bosque
- Umbral de 1 ha para la separación de la pérdida de cobertura arbórea entre deforestación y degradación forestal

### Leyenda
1: no bosque
2: bosque estable
3: degradación
4: deforestación

### Cómo ejecutar la cadena de procesamiento
En SEPAL, abra una terminal e inicie una instancia #4

Clone el repositorio con el siguiente comando:

`` `git clone https://github.com/NREF-guinea-ecuatorial/GNQ_DD_14_18` ``

En SEPAL vaya a Aplicaciones / Rstudio y debajo del directorio de clonación `GNQ_DD_14_18`, abra y` `` source () `` los siguientes scripts en `scrips`:

##### config.R
Este script debe ejecutarse CADA VEZ que su sesión R se reinicie.
Configurará los directorios de trabajo, cargará los paquetes (packages.R), los parámetros correctos (my_parameters.R) y el entorno de las variables.
La primera vez que se ejecuta puede tardar unos minutos, ya que se pueden instalar los paquetes necesarios.
Una vez que se ha ejecutado por primera vez, lleva unos segundos e inicializa todo.

##### gfc_wrapper_GE.R
Descargará los mosaicos de datos necesarios del [repositorio de GFC] (https://earthenginepartners.appspot.com/science-2013-global-forest/download_v1.5.html), fusionará los mosaicos y los recortará en los cuadros que contienen los límites de Guinea Equatorial (GNQ) de la base de datos de las áreas administrativas globales (GADM) (https://uwaterloo.ca/library/geospatial/collections/us-and-world-geospatial-data-resources/global-administrative-areas-gadm).

El resultado de las pérdidas forestales anuales entre 2000 y 2018 `gfc_GNQ_lossyear.tif` se guardará en` data/gfc/ `

(Los resultados de la ganancia de cobertura forestal entre 2000 y 2012 `gfc_GNQ_gain.tif` y el porcentaje de cobertura arbórea de 2000 `gfc_GNQ_treecover2000.tif` también se guardarán en `data/gfc/`). 

##### Import_data.R
Importa los siguientes datos en formato ZIP desde Dropbox al directorio `data`:

- Archivo de segmentación Landsat 2018 de Bioko `bioko3SEPAL5-80-11.zip` y archivo de segmentación Landsat 2018 de la Región Continental` continenteSEPAL5-80-11.zip` en `segmentación`.

- Mapa de deforestación y degradación forestal 2004-14 (mapa DD 2004-14) de Bioko `uni_map_dd_bioko_aea_20171206.zip` y mapa de deforestación y degradación forestal 2004-14 de la Región Continental` uni_map_dd_continente_aea_20171206.zip` en `dd_2004_2014_map`- Clases: No bosque (NF), Bosque intacto (FF), Degradación (DG), Deforestación (DF).

Y los descomprime dentro de sus directorios correspondientes en formatos shapefile (segmentaciones) y TIFF (mapas DD 2004-14).

* Al final de este documento hay una descripción de cómo se realizaron los mosaicos y las segmentaciones de las imágenes Landsat 2018.
** La documentación sobre cómo se realizaron los mapas de deforestación y degradación forestal 2004-14 se encuentra en el documento 'Análisis histórico de la deforestación y degradación forestal en Guinea Ecuatorial 2004-2014' (http://www.fao.org/publications/card/es/c/CA3007ES/). 

##### map_dd_20191014_Bioko.R

PREPARAR MAPA DE PRODUCTOS

Rasteriza la segmentación `bioko3SEPAL5-80-11.shp` en la misma proyección, extensión y tamaño de celda que las del mapa DD 2004-14 `uni_map_dd_bioko_aea_20171206.tif`: `seg_bioko.tif`

ALINEAR PRODUCTOS

Convierte las pérdidas forestales anuales de GFC 2000-2018 `gfc_GNQ_lossyear.tif` en la misma proyección, extensión y tamaño de celda que las del mapa DD 2004-14:` gfc_GNQ_lossyear_aea.tif`

MÁSCARA DE PÉRDIDA / NO PÉRDIDA DE BOSQUE ENTRE 2014-2018

Reclasifica las pérdidas forestales anuales de GFC 2000-2018 en Pérdida (L) o No pérdida (NL) entre 2014-18: `pnp_aea.tif`

NO BOSQUE / BOSQUE INTACTO / BOSQUE DEGRADADO PARA 2015

Reclasifica el mapa DD 2004-14 en No bosque (NF), Bosque intacto (FF), Degradación (DG) y No datos: `bnb_2015.tif`

NO BOSQUE / BOSQUE INTACTO / BOSQUE DEGRADADO PARA 2014

Elimina las pérdidas forestales de 2014 del mapa anterior: `bnb_2014.tif`

RECLASIFICAR CADA GRUPO DE PIXELES DE LA SEGMENTACIÓN EN DEFORESTACIÓN Y DEGRADACIÓN ENTRE 2014-18

Clases:

1: no bosque

2: bosque estable (intacto)

2: bosque estable (degradado)

21: degradación de bosque intacto

22: degradación de bosque degradado

31: deforestación de bosque intacto

32: deforestación de bosque degradado

Reglas:

1: NF (2004-14) -> No bosque

Si FF / DG (2004-14):

2: Bosque estable (intacto o degradado) -> DG (2004-14) <30% y (L (2014-18) de FF/DG (2004-14) <10%) O DG (2004-14)> 30 % y (L (2014-18) de FF/DG (2004-14) <10%)

3: Degradación (de bosque intacto o degradado) -> DG (2004-14) <30% y (L (2014-18) de FF/DG (2004-14)> 10% pero <30%) OR DG (2004 -14)> 30% y (L (2014-18) de FF/DG (2004-14)> 10% pero <30%)

4: Deforestación (en bosque intacto o degradado) -> DG (2004-14) <30% y (L (2014-18) de FF/ G (2004-14)> 30%) OR DG (2004-14)> 30% y (L (2014-18) de FF/DG (2004-14)> 30%)

Producto: `bioko_mapa_2014_2018.tif`

##### map_dd_20191014_Continente.R

PREPARAR MAPA DE PRODUCTOS

Rasteriza la segmentación `continenteSEPAL5-80-11.shp` en la misma proyección, extensión y tamaño de celda que las del mapa DD 2004-14` uni_map_dd_continente_aea_20171206.tif`: `seg_continente.tif`

ALINEAR PRODUCTOS

Convierte las pérdidas forestales anuales de GFC 2000-2018 `gfc_GNQ_lossyear.tif` en la misma proyección, extensión y tamaño de celda que las del mapa DD 2004-14:` gfc_GNQ_lossyear_aea_continente.tif`

MÁSCARA DE PÉRDIDA - NO PÉRDIDA DE BOSQUE PARA 2014-2018

Reclasifica las pérdidas forestales anuales de GFC 2000-2018 en Pérdida (L) o No pérdida (NL) entre 2014-18: `pnp_aea_continente.tif`

NO BOSQUE / BOSQUE INTACTO / BOSQUE DEGRADADO PARA 2015

Reclasifica el mapa DD 2004-14 en No bosque (NF), Bosque intacto (FF), Degradación (DG) y No datos: `bnb_2015_continente.tif`

NO BOSQUE / BOSQUE INTACTO / BOSQUE DEGRADADO PARA 2014

Elimina las pérdidas forestales de 2014 del mapa anterior: `bnb_2014_continente.tif`

RECLASIFICA CADA GRUPO DE PIXELES DE LA SEGMENTACIÓN EN DEFORESTACIÓN Y DEGRADACIÓN ENTRE 2014-18

Las mismas clases y reglas que el script anterior para Bioko.

Producto: `continente_mapa_2014_2018.tif`

##### reclass_map_dd_20191014_Bioko.R

RECLASIFICAR MAPA DE DEFORESTACIÓN Y DEGRADACIÓN DE 2014-18 `bioko_mapa_2014_2018.tif` EN:

1: no bosque estable (clase 1)

2: bosque estable (clase 2)

3: Degradación (uniendo las clases 21-22)

4: Deforestación (uniendo las clases 31-32)

Sin datos: el resto de los valores (0-255)

Producto: `bioko_mapa_2014_2018_reclass.tif`

##### reclass_map_dd_20191014_continente.R

RECLASIFICAR MAPA DE DEFORESTACIÓN Y DEGRADACIÓN DE 2014-18 `continente_mapa_2014_2018.tif` EN:

Las mismas clases que el script anterior para Bioko.

Producto: `continente_mapa_2014_2018_reclass.tif`

-----------

###### Resumen del flujo de datos:

MAPAS BASE

Bioko: `uni_map_dd_bioko_aea_20171206.tif` (mapa DD 2004-14) ->` bnb_2015.tif` (mapa base 1 de enero de 2004 - 1 de enero de 2015, reclasificado en NF, FF, DG) -> `bnb_2014.tif` (mapa base eliminando las pérdidas de 2014 = mapa base 1 de enero de 2004 - 1 de enero de 2014)

Continente: `uni_map_dd_continente_aea_20171206.tif` (mapa DD 2004-14) ->` bnb_2015_continente.tif` (mapa base 1 de enero de 2004 - 1 de enero de 2015, reclasificado en NF, FF, DG) -> `bnb_2014_continente.tif` (mapa base eliminando las pérdidas de 2014 = mapa base 1 de enero de 2004 - 1 de enero de 2014)

SEGMENTACIONES

Bioko: `bioko3SEPAL5-80-11.shp` (segmentación LS18) -> `seg_bioko.tif` (acomodado al mapa DD 2004-14)

Continente: `continente3SEPAL5-80-11.shp` (segmentación LS18) ->` seg_continente.tif` (acomodado al mapa DD 2004-14)

NUEVAS PÉRDIDAS

Bioko: `gfc_GNQ_lossyear.tif` (pérdidas 2000-18) ->` gfc_GNQ_lossyear_aea.tif` (alineado con el mapa anterior) -> `pnp_aea.tif` (pérdidas 2014-18)

Continente: `gfc_GNQ_lossyear.tif` (pérdidas 2000-18) ->` gfc_GNQ_lossyear_aea_continente.tif` (alineado con el mapa anterior) -> `pnp_aea_continente.tif` (pérdidas 2014-18)

NUEVOS MAPAS DD 2014-18

Bioko: `bioko_mapa_2014_2018.tif` (7 clases) ->` bioko_mapa_2014_2018_reclass.tif` (4 clases)

Continente: `continente_mapa_2014_2018.tif` (7 clases) ->` continente_mapa_2014_2018_reclass.tif` (4 clases)

##### Creación de mosaicos Landsat 2018

En SEPAL abra la pestaña Proceso> Crear receta> Crear un mosaico con Landat o Sentinel2.

Los archivos de segmentación Landsat 2018 de Bioko `bioko3SEPAL5-80-11.shp` y de Región continental` continenteSEPAL5-80-11.shp` se basan en los mosaicos creados con las siguientes opciones:


- Fecha objetivo: 31 de diciembre de 2018 para Bioko y 31 de julio para la región continental.
- Incluye temporadas del pasado / futuro: 3 temporadas del pasado / 0 temporadas del futuro
- Satélite: L7 y L8
- Bandas: 5, 4, 3 (SWIR, NIR, RED)
- AOI: dibuja un polígono para Bioko, otro para la región Continental
- Escena: usa todas las escenas
- Corrección: no
- Filtro basado en sombra / NDVI / día del año: ninguno
- 'Buffer'  de nube: ninguno
- Máscara: ninguna
- MEdiana

Los archivos de mosaico Landsat 2018 de Bioko `bioko3SEPAL_2019-07-25_543.tif` y de Región continental` sepal_eg_mainland2018-28-07.tif` se pueden descargar en formato zip desde: https://www.dropbox.com/s/whj42d3vn1ari8j/bioko3SEPAL_2019-07-25_543.zip?dl=0 y https://www.dropbox.com/s/26l98r4sxk8qcy6/sepal_eg_mainland2018-28-07.zip?dl=0 respectivamente.

##### Segmentación de mosaicos Landsat 2018

En SEPAL abra la pestaña  Aplicaciones> GEO Processing Beta> Segmentación de imagenes

La segmentación de los archivos del mosaico Landsat 2018 de Bioko `bioko3SEPAL_2019-07-25_543.tif` y del de Región Continental` sepal_eg_mainland2018-28-07.tif` se realizó con las siguientes opciones:

- Algoritmo de segmentación: desviación de la media
- Radio espacial: 5
- Radio de alcance: 80
- Umbral de convergencia: 0,1
- Max iteraciones: 100
- Tamaño mínimo de la región: 11 (para 1 ha)
- Modo: vector
