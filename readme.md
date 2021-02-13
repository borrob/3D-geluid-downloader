# 3D Omgevingsmodel voor geluid - downloadtool

Op [PDOK](https://www.pdok.nl) is het 3D omgevingsmodel voor geluid te vinden. Dit is een dataset
specifiek voor geluidberekening. De dataset heeft een landelijke dekking en beslaat:
- bodemvlakken met aanduiding bodemfactor
- TIN voor het hoogtemodel maaiveld
- gebouwen met hoogteinformatie

## Downloaden

De dataset is te downloaden als geopackage en de dataset is opgedeeld in verschillende
kaartbladen. Voor een willekeurig project in Nederland kan het misschien lastig zijn om snel een
overzicht te maken van de relevante kaartbladen, deze te downloaden en te combineren tot een
samengevoegd bestand. Daar kan deze tool misschien bij helpen.

## Werking tool
Maak een shape bestand (polygoon) van het gebied waarin je geintreseerd bent en noem die
`roi.shp`. Zet dit shape-bestand in deze directory (direct naast het script `downloader.sh` en
vuur het script `downloader.sh` af. Het script zoekt de relevante kaartbladnummers op en downloadt
de relevante files van PDOK. De bestanden worden uitgepakt en geclipt met de `roi.shp`.
Uiteindelijk is er een nieuwe geopackage `dataset.gpkg` met daarin drie layers voor de
bodemvlakken, TIN en gebouwen.

Deze kaartlagen zijn in een GIS-software in te laden, waarin nog mogelijke nabwerkingen gedaan
kunnen worden en een export kan worden gemaakt die ingelezen kan worden door een
geluidrekenprogramma.

## Afhankelijkheden

De tool maakt gebruikt van `unzip`, `sed`, `curl`, `ogr2ogr` en `ogrinfo`. De laatste twee komen
uit de `GDAL` package.Het is bedoeld om op een linux-omgeving te worden gedraait via `bash`.

# Kaartbladen index

De index van de AHN3 kaartbladen in de `hulpdata.gpkg` is afkomstig van PDOK en deze dataset is
vrij gepubliceerd onder de Creative Commones Licentie.
