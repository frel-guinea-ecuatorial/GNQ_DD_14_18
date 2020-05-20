# install.packages("googledrive")
# library("googledrive")

# setwd("~/GNQ_DD_14_18/data/segmentation")

# drive_download("https://drive.google.com/file/d/1lul2WR-d4qYHnvpf4wI7D9nz98hM5P6y/view?usp=sharing")

## Import segmentation files of Bioko and Continente into the segmentation directory
system(sprintf("wget -O %s  https://www.dropbox.com/s/bde6w618wymo0mt/bioko3SEPAL5-80-11.zip?dl=0", paste0(seg_dir,'bioko3SEPAL5-80-11.zip')))
system(sprintf("wget -O %s  https://www.dropbox.com/s/r0jru2w525cz4e7/continenteSEPAL5-80-11.zip?dl=0", paste0(seg_dir,'continenteSEPAL5-80-11.zip')))

## Import deforestation and forest degradation maps of 2004-14 into the dd_2004_2014_map directory
system(sprintf("wget -O %s  https://www.dropbox.com/s/f3eic9nwvvn2rdz/uni_map_dd_bioko_aea_20171206.zip?dl=0", paste0(edd_dir,'uni_map_dd_bioko_aea_20171206.zip')))
system(sprintf("wget -O %s  https://www.dropbox.com/s/g63no1o2h5cywrf/uni_map_dd_continente_aea_20171206.zip?dl=0", paste0(edd_dir,'uni_map_dd_continente_aea_20171206.zip')))

## Unzip the previous files inside their corresponding directories
system(sprintf("unzip -o %s -d %s ",paste0(seg_dir,'bioko3SEPAL5-80-11.zip'), seg_dir))
system(sprintf("unzip -o %s -d %s ",paste0(seg_dir,'continenteSEPAL5-80-11.zip'), seg_dir))
system(sprintf("unzip -o %s -d %s ",paste0(edd_dir,'uni_map_dd_bioko_aea_20171206.zip'), edd_dir))
system(sprintf("unzip -o %s -d %s ",paste0(edd_dir,'uni_map_dd_continente_aea_20171206.zip'), edd_dir))

## When you change 1 for 0 it downloads directly into the download folder of your pc
#https://www.dropbox.com/s/bde6w618wymo0mt/bioko3SEPAL5-80-11.zip?dl=0
#https://www.dropbox.com/s/bde6w618wymo0mt/bioko3SEPAL5-80-11.zip?dl=1


#Is it OK to cache OAuth access credentials in the folder 'C:/Users/support/.R/gargle/gargle-oauth' between R sessions?
  
  #1: Yes
  #2: No
  
  



