#!/bin/bash

# Opschonen oude runs
rm -f dataset.gpkg
rm -f bladnummers.csv
rm -rf download
mkdir download
mkdir download/tin
mkdir download/bodem
mkdir download/gebouwen

# Zoek bladindex op
ogr2ogr -select "bladnr" -f csv bladnummers.csv hulpdata.gpkg ahn_bladindex -clipsrc roi.shp
sed -i -e '1d' bladnummers.csv # header line verwijderen

# Downloaden TIN en bodemvlakken
while read -u 10 p; do
    echo "Downloaden van TIN bladnummer: $p"
    curl -L -o "download/tin/tin_$p.zip" "https://download.pdok.nl/kadaster/3d-geluid/v1_0/2019/tin/${p}_2019_TIN.zip"
    echo "Downloaden van bodemvlak bladnummer: $p"
    curl -L -o "download/bodem/bodem_$p.zip" "https://download.pdok.nl/kadaster/3d-geluid/v1_0/2019/bodemvlakken/${p}_2019_bodemvlakken.zip"
done 10<bladnummers.csv

# Downloaden gebouwen
curl -L -o "download/gebouwen/gebouwen.zip" "https://download.pdok.nl/kadaster/3d-geluid/v1_0/2019/gebouwen/2019_NL_3d_geluid_gebouwen.zip"

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

# Bodemvlakken knippen
for f in download/bodem/*.gpkg; do
    echo "Bodem clippen: $f"
    # Hier enkel bodemfactor = 1 meenemen (naar smaak aanpassen)
    ogr2ogr -f gpkg -where "bodemfactor=1" -append -t_srs EPSG:28992 dataset.gpkg $f -nln bodem -clipsrc roi.shp -nlt POLYGON
done

# TIN knippen
for f in download/tin/*.gpkg; do
    echo "TIN clippen: $f"
    ogr2ogr -progress -f gpkg -append -t_srs EPSG:28992 dataset.gpkg $f -nln tin -clipsrc roi.shp -nlt POLYGON
done

# Gebouwen knippen
for f in download/gebouwen/*.gpkg; do
    echo "Gebouwen clippen"
    ogr2ogr -progress -f gpkg -append -t_srs EPSG:28992 dataset.gpkg "$f" -nln gebouwen -clipsrc roi.shp -nlt POLYGON
done

# Opschonen voor QGIS
ogrinfo dataset.gpkg -sql "drop table rtree_bodem_geom"
ogrinfo dataset.gpkg -sql "drop table rtree_tin_geom"
ogrinfo dataset.gpkg -sql "drop table rtree_gebouwen_geom"

# Optie: verwijderen downloadmap om ruimte vrij te maken
# rm -rd download
