#!/bin/bash

input_file=''
clip=false

while getopts 'ci:' flag; do
    case "${flag}" in
        c) clip=true;;
        i) input_file=${OPTARG};;
    esac
done

if [ "$input_file" == '' ]; then
    exit 1
fi

echo ${clip}
echo ${input_file}

# Opschonen oude runs
rm -f dataset.gpkg
#rm -f bladnummers.csv
#rm -rf download
#mkdir download
#mkdir download/tin
#mkdir download/bodem
#mkdir download/gebouwen
#
# Zoek bladindex op
#gr2ogr -select "bladnr" -f csv bladnummers.csv hulpdata.gpkg ahn_bladindex -clipsrc ${input_file}
#ed -i -e '1d' bladnummers.csv # header line verwijderen
#
## Downloaden TIN en bodemvlakken
#while read -u 10 p; do
#    echo "Downloaden van TIN bladnummer: $p"
#    curl -L -o "download/tin/tin_$p.zip" "https://download.pdok.nl/kadaster/3d-geluid/v1_0/2019/tin/${p}_2019_TIN.zip"
#    echo "Downloaden van bodemvlak bladnummer: $p"
#    curl -L -o "download/bodem/bodem_$p.zip" "https://download.pdok.nl/kadaster/3d-geluid/v1_0/2019/bodemvlakken/${p}_2019_bodemvlakken.zip"
#done 10<bladnummers.csv
#
## Downloaden gebouwen
#curl -L -o "download/gebouwen/gebouwen.zip" "https://download.pdok.nl/kadaster/3d-geluid/v1_0/2019/gebouwen/2019_NL_3d_geluid_gebouwen.zip"
#
## Unzip
#pushd download/bodem
#for f in *.zip; do
#    unzip -o $f
#    rm $f
#done
#popd
#
#pushd download/tin
#for f in *.zip; do
#    unzip -j -o $f
#    rm $f
#done
#popd
#
#pushd download/gebouwen
#for f in *.zip; do
#    unzip -o $f
#    rm $f
#done
#popd

# Bodemvlakken plakken
for f in download/bodem/*.gpkg; do
    echo "Bodem clippen: $f"
    # Hier enkel bodemfactor = 1 meenemen (naar smaak aanpassen)
    ogr2ogr -f gpkg -where "bodemfactor=1" -append -t_srs EPSG:28992 dataset.gpkg $f -nln bodem -nlt POLYGON
done

# TIN plakken
for f in download/tin/*.gpkg; do
    echo "TIN clippen: $f"
    ogr2ogr -progress -f gpkg -append -t_srs EPSG:28992 dataset.gpkg $f -nln tin -nlt POLYGON
done

# Gebouwen knippen
for f in download/gebouwen/*.gpkg; do
    echo "Gebouwen clippen"
    ogr2ogr -progress -f gpkg -append -t_srs EPSG:28992 dataset.gpkg "$f" -nln gebouwen -clipsrc ${input_file} -nlt POLYGON
done

# Bodemvlakken knippen
if [ "$clip" = true ]; then
    ogr2ogr -progress -f gpkg dataset.gpkg dataset.gpkg bodemvlakken -nln bodemvlakken_clip -clipsrc ${input_file} -nlt POLYGON 
    ogrinfo dataset.gpkg -sql "drop table bodemvlakken"
fi

# TIN knippen
if [ "$clip" = true ]; then
    ogr2ogr -progress -f gpkg dataset.gpkg dataset.gpkg tin -nln tin_clip -clipsrc ${input_file} -nlt POLYGON 
    ogrinfo dataset.gpkg -sql "drop table tin"
fi

# Opschonen voor QGIS
ogrinfo dataset.gpkg -sql "drop table rtree_gebouwen_geom"
if [ "$clip" = true ]; then
    ogrinfo dataset.gpkg -sql "drop table rtree_bodem_clip_geom"
    ogrinfo dataset.gpkg -sql "drop table rtree_tin_clip_geom"
else
    ogrinfo dataset.gpkg -sql "drop table rtree_bodem_geom"
    ogrinfo dataset.gpkg -sql "drop table rtree_tin_geom"
fi

## Optie: verwijderen downloadmap om ruimte vrij te maken
## rm -rf download
