# Processing chain for the generation of activity data for the Equatorial Guinea REDD+ process
The material on this repo has been developed to run inside SEPAL (https://sepal.io)

The aim of the processing chain is to develop activity data for the FREL of Equatorial Guinea 

## Characteristics of the FREL 
The FREL combines the 'deforestation an forest degradation map of 2004-14', which was developed from the GFC dataset, with the new forest losses between 2014-2018 also from the GFC dataset, to produce the new 'deforestation and degradation map of 20014-18'.

- Period of 2014-2018 (5 years)
- 30% canopy cover threshold for the forest definition
- 1ha threshold for separation of tree cover loss between deforestation and forest degradation

### Legend
1: Non Forest
2: Stable Forest
3: Degradation
4: Deforestation

### How to run the processing chain
In SEPAL, open a terminal and start an instance #4 

Clone the repository with the following command:

``` git clone https://github.com/frel-guinea-ecuatorial/GNQ_DD_14_18 ```

Open the SEPAL tab Apps / Rstudio and under the clone directory `GNQ_DD_14_18`, open and ``` source()``` the following scripts under `scrips`:

#### config.R
This script needs to be run EVERY TIME your R session is restarted. 
It will setup the working directories, load the packages (packages.R), the right parameters (my_parameters.R) and variables environment.
The first time it runs, it can take a few minutes as the necessary packages may be installed.
Once it has run the first time, it takes a few seconds and initializes everything.

#### gfc_wrapper_GE.R 
It will download the necessary data tiles  from [GFC repository](https://earthenginepartners.appspot.com/science-2013-global-forest/download_v1.5.html), merge tiles together and clip it to the boundaing boxes of Equatorial Guinea (GNQ) from the Global Administrative Areas (GADM) database (https://uwaterloo.ca/library/geospatial/collections/us-and-world-geospatial-data-resources/global-administrative-areas-gadm).

Result of annual forest losses between 2000 and 2018 `gfc_GNQ_lossyear.tif` will be saved in `data/gfc/`

(Results of forest cover gain between 2000 and 2012 `gfc_GNQ_gain.tif` and tree cover percentage of 2000 `gfc_GNQ_treecover2000.tif` will also be saved in `data/gfc/`).

#### Import_data.R
It imports the followning data in ZIP format from dropbox inside the `data` directory: 

- Landsat 2018 segmentation file of Bioko `bioko3SEPAL5-80-11.zip` and Landsat 2018 segmentation file of Continental Region `continenteSEPAL5-80-11.zip` in `segmentation`.

- Deforestation and forest degradation map 2004-14 (DD map 2004-14) of Bioko `uni_map_dd_bioko_aea_20171206.zip` and deforestation and forest degradation map 2004-14 of Continental Region `uni_map_dd_continente_aea_20171206.zip` in `dd_2004_2014_map`- Clases: Non forest (NF), Intact Forest (FF), Degradation (DG), Deforestation (DF). 

And unzip them inside their corresponding directories in shapefile (segmentations) and TIFF (DD 2004-14 maps) formats.

*At the end of this document there is a description on how the mosaicking and segmentations from 2018 Landsat imagery were done. 
**The documentation on how the Deforestation and forest degradation maps 2004-14 were done is in the 'Análisis histórico de la deforestación y degradación forestal en Guinea Ecuatorial 2004–2014' document (http://www.fao.org/publications/card/en/c/CA3007ES/). 

#### map_dd_20191014_Bioko.R 

PREPARE COMMODITY MAP

Rasterize the segmentation `bioko3SEPAL5-80-11.shp` to the same projection, extent and cell size of the DD map 2004-14 `uni_map_dd_bioko_aea_20171206.tif`: `seg_bioko.tif`

ALIGN PRODUCTS

Convert GFC annual forest losses 2000-2018 `gfc_GNQ_lossyear.tif` to the same projection, extent and cell size of the DD map 2004-14: `gfc_GNQ_lossyear_aea.tif`

LOSS / NO LOSS MASK FOR 2014-2018

Reclassify GFC annual forest losses 2000-2018 into Loss (L) or Non loss (NL) between 2014-18: `pnp_aea.tif`

NON FOREST / INTACT FOREST / DEGRADED FOREST FOR 2015

Reclassify the DD map 2004-14 into Non forest (NF), Intact Forest (FF), Degradation (DG) and Non Data: `bnb_2015.tif` 

NON FOREST / INTACT FOREST / DEGRADED FOREST FOR 2014

Remove the forest losses of 2014 from the previous map: `bnb_2014.tif`

RECLASS EACH GROUP OF PIXELS FROM THE SEGMENTATION INTO DEFORESTATION AND DEGRADATION BETWEEEN 2014-18

Clases:

1: non forest 
 
2: stable forest (intact)

2: stable forest (degraded)

21: degradation of intact forest

22: degradation of degraded forest

31: deforestation of intact forest

32: deforestation of degraded forest

Rules: 

1: NF(2004-14)-> Non Forest

Si FF/DG(2004-14):

 2: Stable Forest (intact OR degraded)-> DG(2004-14) <30% and (L(2014-18) of FF/DG(2004-14) <10%) OR DG(2004-14) >30% and (L(2014-18) of FF/DG(2004-14) <10%)

 3: Degradation (in intact OR degraded forest)-> DG(2004-14) <30% and (L(2014-18) of FF/DG(2004-14) >10% but <30%)  OR DG(2004-14) >30% and (L(2014-18)  of FF/DG(2004-14) >10% but <30%)

 4: Deforestation (in intact OR degraded forest) -> DG(2004-14) <30% and (L(2014-18) of FF/DG(2004-14) >30%)  OR DG(2004-14) >30% and (L(2014-18)  of FF/DG(2004-14) >30%)

Output: `bioko_mapa_2014_2018.tif`

#### map_dd_20191014_Continente.R

PREPARE COMMODITY MAP

Rasterized the segmentation `continenteSEPAL5-80-11.shp` to the same projection, extent and cell size of the DD map 2004-14 `uni_map_dd_continente_aea_20171206.tif`: `seg_continente.tif`

ALIGN PRODUCTS

Convert GFC annual forest losses 2000-2018 `gfc_GNQ_lossyear.tif` to the same projection, extent and cell size of the DD map 2004-14: `gfc_GNQ_lossyear_aea_continente.tif`

LOSS - NO LOSS MASK FOR 2014-2018

Reclassify GFC annual forest losses 2000-2018 into Loss (L) or Non loss (NL) between 2014-18: `pnp_aea_continente.tif`

FOREST - NON FOREST - DEGRADED FOR 2015

Reclassify the DD map 2004-14 into Non forest (NF), Intact Forest (FF), Degradation (DG) and Non Data: `bnb_2015_continente.tif` 

FOREST - NON FOREST - DEGRADED FOR 2014

Remove the forest losses of 2014 to the previous map: `bnb_2014_continente.tif`

RECLASS EACH GROUP OF PIXELS FROM THE SEGMENTATION INTO DEFORESTATION AND DEGRADATION BETWEEEN 2014-18

The same classes and rules than the previous script for Bioko.

Output: `continente_mapa_2014_2018.tif`

#### reclass_map_dd_20191014_Bioko.R

RECLASS DEFORESTATION AND DEGRADATION MAP 2014-18 `bioko_mapa_2014_2018.tif` INTO:

1: No stable forest (class 1)

2: Stable forest (class 2)

3: Degradation (joining classes 21-22)

4: Deforestation (joining classes 31-32)

No data: the rest of the values (0-255)

Output: `bioko_mapa_2014_2018_reclass.tif` 

#### reclass_map_dd_20191014_continente.R

RECLASS DEFORESTATION AND DEGRADATION MAP 2014-18 `continente_mapa_2014_2018.tif` INTO:

The same clases as the previous script for Bioko.

Output: `continente_mapa_2014_2018_reclass.tif`

-----------

### Summary of the data flow: 

BASE MAPS

Bioko:  `uni_map_dd_bioko_aea_20171206.tif` (DD 2004-14 map) -> `bnb_2015.tif` (base map 1st January 2004 - 1st January 2015, reclassified into NF, FF, DG) -> `bnb_2014.tif`  (base map removing the 2014 losses = base map 1st January 2004 - 1st January 2014)

Continente:  `uni_map_dd_continente_aea_20171206.tif` (DD 2004-14 map) -> `bnb_2015_continente.tif` (base map 1st January 2004 - 1st January 2015, reclassified into NF, FF, DG) -> `bnb_2014_continente.tif`  (base map removing the 2014 losses = base map 1st January 2004 - 1st January 2014)  

SEGMENTATIONS

Bioko: `bioko3SEPAL5-80-11.shp` (LS18 segmentation) -> `seg_bioko.tif` (accommodated to the DD 2004-14 map)

Continente: `continente3SEPAL5-80-11.shp` (LS18 segmentation) -> `seg_continente.tif` (accommodated to the DD 2004-14 map)

NEW LOSSES

Bioko: `gfc_GNQ_lossyear.tif`(losses 2000-18) -> `gfc_GNQ_lossyear_aea.tif` (aligned to previous map) -> `pnp_aea.tif` (losses 2014-18)

Continente: `gfc_GNQ_lossyear.tif` (losses 2000-18) -> `gfc_GNQ_lossyear_aea_continente.tif` (aligned to previous map) -> `pnp_aea_continente.tif` (losses 2014-18)

NEW DD 2014-18 MAPS

Bioko: `bioko_mapa_2014_2018.tif` (7 classes) -> `bioko_mapa_2014_2018_reclass.tif` (4 classes)

Continente: `continente_mapa_2014_2018.tif` (7 classes) -> `continente_mapa_2014_2018_reclass.tif` (4 classes)

### Creation of Landsat 2018 mosaics  

Open the SEPAL tab Process> Create recipe> Create a mosaic using Landat or Sentinel2.

The Landsat 2018 segmentation files of Bioko `bioko3SEPAL5-80-11.shp` and Continental Region `continenteSEPAL5-80-11.shp` are based on the mosaics created with the following choices: 


-	Target date: 31st December 2018 for Bioko and 31st July for Continental Region. 
-	Include seasons from the past/future: 3 seasons from past / 0 season from future
-	Satellite: L7 & L8 
-	Bands: 5, 4, 3 (SWIR, NIR, RED)
-	AOI: draw a polygon for Bioko, another for mainland
-	Scene: use all scenes
-	Correction:  no 
-	Filter based on shadow / NDVI / day of the year: none
-	Cloud buffering: none
-	Mask: none
-	MEdian

The Landsat 2018 mosaic files of Bioko `bioko3SEPAL_2019-07-25_543.tif` and Continental Region `sepal_eg_mainland2018-28-07.tif` can be downloaded in zip format from: https://www.dropbox.com/s/whj42d3vn1ari8j/bioko3SEPAL_2019-07-25_543.zip?dl=0 and  https://www.dropbox.com/s/26l98r4sxk8qcy6/sepal_eg_mainland2018-28-07.zip?dl=0 respectively.

### Segmentation of Landsat 2018 mosaics 

Open the SEPAL tab Apps> GEO Processing Beta> Image segmentation

The segmentation of the Landsat 2018 mosaic files of Bioko `bioko3SEPAL_2019-07-25_543.tif` and Continental Region `sepal_eg_mainland2018-28-07.tif` was done with the following choices: 

-	Segmentation algorithm: meanshift
-	Spatial radius: 5
-	Range radius: 80
-	Convergence Threshold: 0,1
-	Max Iterations: 100
-	Min Region Size: 11 (for 1 ha)
-	Mode: vector

