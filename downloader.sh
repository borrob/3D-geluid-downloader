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

# Opschonen oude runs
rm -f dataset.gpkg
rm -f bladnummers.csv
rm -rf download
mkdir download
mkdir download/tin
mkdir download/bodem
mkdir download/gebouwen

# Zoek bladindex op
ogr2ogr -select "bladnr" -f csv bladnummers.csv hulpdata.gpkg ahn_bladindex -clipsrc ${input_file}
sed -i -e '1d' bladnummers.csv # header line verwijderen

# Downloaden TIN en bodemvlakken
while read -u 10 p; do
    echo "Downloaden van TIN bladnummer: $p"
    curl -L --retry 3 -o "download/tin/tin_$p.zip" "https://download.pdok.nl/kadaster/3d-geluid/v1_0/2019/tin/${p}_2019_TIN.zip"
    echo "Downloaden van bodemvlak bladnummer: $p"
    curl -L --retry 3 -o "download/bodem/bodem_$p.zip" "https://download.pdok.nl/kadaster/3d-geluid/v1_0/2019/bodemvlakken/${p}_2019_bodemvlakken.zip"
done 10<bladnummers.csv

# Downloaden gebouwen
curl -L --retry 3 -o "download/gebouwen/gebouwen.zip" "https://download.pdok.nl/kadaster/3d-geluid/v1_0/2019/gebouwen/2019_NL_3d_geluid_gebouwen.zip"

# Unzip
pushd download/bodem
for f in *.zip; do
    unzip -o $f
    rm $f
done
popd

pushd download/tin
for f in *.zip; do
    unzip -j -o $f
    rm $f
done
popd

pushd download/gebouwen
for f in *.zip; do
    unzip -o $f
    rm $f
done
popd

# Voor clippen: temp dataset aanmaken
if [ "${clip}" = true ]; then
    output="data_tmp.gpkg"
else
    output="dataset.gpkg"
fi
echo ${output}

# Bodemvlakken plakken
for f in download/bodem/*.gpkg; do
    echo "Bodem toevoegen: $f"
    # Hier enkel bodemfactor = 1 meenemen (naar smaak aanpassen)
    ogr2ogr -f gpkg -where "bodemfactor=1" -append -t_srs EPSG:28992 ${output} $f -nln bodem -nlt POLYGON
done

# TIN plakken
for f in download/tin/*.gpkg; do
    echo "TIN toevoegen: $f"
    ogr2ogr -progress -f gpkg -append -t_srs EPSG:28992 ${output} $f -nln tin -nlt POLYGON
done

# Gebouwen knippen
for f in download/gebouwen/*.gpkg; do
    echo "Gebouwen clippen en toevoegen"
    ogr2ogr -progress -f gpkg -append -t_srs EPSG:28992 dataset.gpkg "$f" -nln gebouwen -clipsrc ${input_file} -nlt POLYGON
done

# Bodemvlakken knippen
if [ "$clip" = true ]; then
    ogr2ogr -progress -f gpkg -append dataset.gpkg ${output} bodem -nln bodem -clipsrc ${input_file} -nlt POLYGON 
fi

# TIN knippen
if [ "$clip" = true ]; then
    ogr2ogr -progress -f gpkg -append dataset.gpkg ${output} tin -nln tin -clipsrc ${input_file} -nlt POLYGON 
fi

# Opschonen voor QGIS
ogrinfo dataset.gpkg -sql "drop table rtree_gebouwen_geom"
ogrinfo dataset.gpkg -sql "drop table rtree_bodem_geom"
ogrinfo dataset.gpkg -sql "drop table rtree_tin_geom"
if [ "$clip" = true ]; then
    rm -f data_tmp.gpkg
fi

# Optie: verwijderen downloadmap om ruimte vrij te maken
rm -rf download
