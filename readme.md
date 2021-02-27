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
Maak een shape bestand (polygoon) van het gebied waarin je geintreseerd bent (bijvoorbeeld: 
`roi.shp`). 
Vuur het script `downloader.sh` af en geeef als argument het pad naar de roi.shp mee (gebruik
hiervoor de `-i` aanduiging. Bijvoorbeeld:

```bash
./downloader.sh -i roi.shp
```

Het script zoekt de relevante kaartbladnummers op en downloadt
de relevante files van PDOK. De bestanden worden uitgepakt.
Uiteindelijk is er een nieuwe geopackage `dataset.gpkg` met daarin drie layers voor de
bodemvlakken, TIN en gebouwen.

Deze kaartlagen zijn in een GIS-software in te laden, waarin nog mogelijke nabwerkingen gedaan
kunnen worden en een export kan worden gemaakt die ingelezen kan worden door een
geluidrekenprogramma. **Let op:** het TIN-bestand met hoogtelijnen kan behoorlijk groot worden van
bestandsgrootte en aantal features.

### Clippen
Het is ook mogelijk om de TIN en de bodemvlakken meteen al te clippen met de inputshape (de
gebouwen worden al gelclipt). Gebruik hier voor de `-c` vlag:

```bash
./downloader.sh -i roi.shop -c
```

Het clippen van de TIN en de bodemvlakken is misschien niet per se nodig, maar het vergt wel een
behoorlijke aanslag op de processor en doorlooptijd.

## Afhankelijkheden

De tool maakt gebruikt van `unzip`, `sed`, `curl`, `ogr2ogr` en `ogrinfo`. De laatste twee komen
uit de `GDAL` package. Het is bedoeld om op een linux-omgeving te worden gedraait via `bash`.

# Kaartbladen index

De index van de AHN3 kaartbladen in de `hulpdata.gpkg` is afkomstig van PDOK en deze dataset is
vrij gepubliceerd onder de Creative Commons Licentie. Zie de [beschrijving op het Nationaal
Georegister](https://www.nationaalgeoregister.nl/geonetwork/srv/dut/catalog.search#/metadata/41daef8b-155e-4608-b49c-c87ea45d931c?tab=general)
voor meer informatie.
