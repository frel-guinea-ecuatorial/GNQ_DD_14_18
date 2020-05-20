# Processing chain for the generation of activity data for the Equatorial Guinea REDD+ process
The material on this repo has been developed to run inside SEPAL (https://sepal.io)

The aim of the processing chain is to develop activity data for the FREL of Equatorial Guinea 

## Characteristics of the FREL 
The FREL combine the 'deforestation an forest degradation map of 2004-14', which was developed from the GFC dataset, with the new forest losses between 2014-2018 also from the GFC dataset, to produce the new 'deforestation and degradation map of 20014-18'.

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

Open another SEPAL tab, go to Apps/ Rstudio and under the clone directory ´ `GNQ_DD_14_18`, open and ``` source()``` the following scripts under `scrips`:

##### config.R
This script needs to be run EVERY TIME your R session is restarted. 
It will setup the working directories, load the packages (packages.R), the right parameters (my_parameters.R) and variables environment.
The first time it runs, it can take a few minutes as the necessary packages may be installed.
Once it has run the first time, it takes a few seconds and initializes everything.

##### gfc_wrapper_GE.R 
It will download the necessary data tiles  from [GFC repository](https://earthenginepartners.appspot.com/science-2013-global-forest/download_v1.5.html), merge tiles together and clip it to the boundaing boxes of Equatorial Guinea (GNQ) from the Global Administrative Areas (GADM) database (https://uwaterloo.ca/library/geospatial/collections/us-and-world-geospatial-data-resources/global-administrative-areas-gadm).

Result of forest year losses between 2000 and 2018 `gfc_GNQ_lossyear.tif` will be saved in `data/gfc/`

(Results of forest cover gain between 2000 and 2012 `gfc_GNQ_gain.tif` and tree cover percentage of 2000 `gfc_GNQ_treecover2000.tif` will also be saved in `data/gfc/`).

##### Import_data.R
It imports the followning data in ZIP format from dropbox inside the `data` directory: 

-Landsat 2018 segmentation file of Bioko `bioko3SEPAL5-80-11.zip` and Landsat 2018 segmentation file of Continental Region `continenteSEPAL5-80-11.zip` in `segmentation`.
-Deforestation and forest degradation map 2004-14 (DD map 2004-14) of Bioko `uni_map_dd_bioko_aea_20171206.zip` and deforestation and forest degradation map 2004-14 of Continental Region `uni_map_dd_continente_aea_20171206.zip` in `dd_2004_2014_map`.

And unzip them inside their corresponding directories in SHP (segmentations) and TIF (DD 2004-14 maps) formats.

*In docs there is a description on how the mosaicking and segmentations from 2018 landsat imagery were done. 
*The documentation on how the Deforestation and forest degradation maps 2004-14 were done is in the 'Análisis histórico de la deforestación y degradación forestal en Guinea Ecuatorial 2004–2014' document (http://www.fao.org/publications/card/en/c/CA3007ES/). 

##### map_dd_20191014.R

PREPARE COMMODITY MAP
Rasterized the segmentation `bioko3SEPAL5-80-11.shp`to the same projection, extent and cell size of the DD map 2004-14 `uni_map_dd_bioko_aea_20171206.tif`: `seg_bioko.tif`.

ALIGN PRODUCTS PL1
Convert GFC forest year losses 2000-2018 `gfc_GNQ_lossyear.tif` to the same projection, extent and cell size of the DD map 2004-14: `gfc_GNQ_lossyear_aea.tif`.

LOSS NO LOSS MASK FOR 2014-2018
Reclassify GFC forest year losses 2000-2018 into Loss (L) or Non loss (NL) between 2014-18 (`pnp_aea.tif`). 

FOREST NON FOREST DEGRADED FOR 2015
Reclassify the DD map 2004-14 into Non forest (NF), Intact Forest (FF), Degradation (DG) and Non Data (`bnb_2015.tif`). 

FOREST NON FOREST DEGRADED FOR 2014
Remove the forest losses of 2014 to the previous map (`bnb_2014.tif`)

RECLASS EACH GROUP OF PIXELS FROM THE SEGMENTATION INTO DEFORESTATION AND DEGRADATION BETWEEEN 2014-18
Clases:
1 – non forest
32 – deforestation of degraded forest
21 - degradation of degraded forest
2 – stable forest (degraded)
31 – deforestation of intact forest
21 – degradation of intact forest
2 – stable forest (intact)

Rules: 
1: NF(2004-14)-> Non Forest

Si FF/DG(2004-14):
2: Stable Forest (intact OR degraded)-> DG(2004-14) <30% and (L(2014-18) of FF/DG(2004-14) <10%) OR DG(2004-14) >30% and (L(2014-18) of FF/DG(2004-14) <10%)
3: Degradation (in intact OR degraded forest)-> DG(2004-14) <30% and (L(2014-18) of FF/DG(2004-14) >10% but <30%)  OR DG(2004-14) >30% and (L(2014-18)  of FF/DG(2004-14) >10% but <30%)
4: Deforestation (in intact OR degraded forest) -> DG(2004-14) <30% and (L(2014-18) of FF/DG(2004-14) >30%)  OR DG(2004-14) >30% and (L(2014-18)  of FF/DG(2004-14) >30%)

(output: bioko_mapa_2014_2018.tif)

##### reclass_map_dd_20191002.R

1- No stable forest
2- Stable forest
3- Degradation (joining classes 21-22)
4- Deforestation (joining classes 31-32)
no data- the rest of the values (0-255)

FALTA CAMBIAR COLORES DE DEGRADACIÓN (NARANJA) Y DEFORESTACION (ROJO)
(output: bioko_mapa_2014_2018_reclass.tif)

-----------

Summary of data flow: 

1. `uni_map_dd_bioko_aea_20171206.tif` -> `bnb_2015.tif` (mapa base January 2004 - 1 January 2015, reclassified in NF, FF, DG) -> `bnb_2014.tif`  (mapa base removing the 2014 losses-> mapa base January 2004 - 1 January 2014) -> 

2. `gfc_GNQ_lossyear.tif` -> `gfc_GNQ_lossyear_aea.tif` (aligned to previous map) -> `pnp_aea.tif` (losses 2014-18)

3. `bioko3SEPAL5-80-11.shp` -> `seg_bioko.tif` (accomodated to the DD 2004-14 map)

