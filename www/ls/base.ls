percentage = ->
  decimals = if it < 0.01 then 1 else 0
  "#{window.ig.utils.formatNumber it * 100, decimals}&nbsp;%"

container = d3.select ig.containers.base
mapElement = container.append \div
  ..attr \class \map

map = L.map do
  * mapElement.node!
  * minZoom: 7,
    maxZoom: 12,
    zoom: 7,
    center: [49.78, 15.5]
    maxBounds: [[48.3,11.6], [51.3,19.1]]
baseLayer = L.tileLayer do
  * "https://samizdat.cz/tiles/ton_b1/{z}/{x}/{y}.png"
  * zIndex: 1
    opacity: 0.8
    attribution: 'CC BY-NC-SA <a href="http://rozhlas.cz">Rozhlas.cz</a>. Data <a href="https://www.czso.cz/" target="_blank">ČSÚ</a>, mapová data &copy; přispěvatelé <a target="_blank" href="http://osm.org">OpenStreetMap</a>, obrazový podkres <a target="_blank" href="http://stamen.com">Stamen</a>, <a target="_blank" href="https://samizdat.cz">Samizdat</a>'

labelLayer = L.tileLayer do
  * "https://samizdat.cz/tiles/ton_l1/{z}/{x}/{y}.png"
  * zIndex: 3
    opacity: 0.8
kandidati =
  * name: "Čs.strana socialistická"
    color: \#FB9A99
  * name: "Svobodný blok"
    color: \#222
  * name: "Občanské fórum"
    color: \#006ab3
    map: 'of'
  * name: "Všelid.dem.str.,Sdruž.pro rep. "
    color: \#444
  * name: "Volební seskup.zájm.svazů v ČR"
    color: \#666
  * name: "Komunistická strana Českoslov"
    color: \#e3001a
    map: 'ksc'
  * name: "Spojenectví zeměděl.a venkova"
    color: \#e0f
    map: 'zemedel'
  * name: "Čs.demokratické fórum"
    color: \#888
  * name: "Strana zelených"
    color: \#00AD00
    map: 'sz'
  * name: "Hnutí za sam.dem.-Sp.Mor.a Sl."
    color: \#00e5ff
    map: 'morava'
  * name: "Sociální demokracie"
    color: \#f29400
    map: 'socdem'
  * name: "Strana přátel piva"
    color: \#000
  * name: "Křesťanská a demokratická unie"
    color: \#FFCC03
    map: 'kdu'

grid = new L.UtfGrid "../data/tiles/meta/{z}/{x}/{y}.json", useJsonP: no
  ..on \mouseover ({data}:e) ->
    [nazev, volicu, obalek, ...strany] = data
    infobar.displayData {nazev, volicu, obalek, strany}
  # ..on \mouseout ->
  #   infobar.reInit!

map
  ..addLayer baseLayer
  ..addLayer labelLayer
  ..addLayer grid
dataLayers = {}
winnersLayer = dataLayers["winners"] = L.tileLayer do
    * "../data/tiles/narodni-rada-vitezove/{z}/{x}/{y}.png"
    * opacity: 0.9
      zIndex: 2
winnersLayerShaded = dataLayers["winners-amount"] = L.tileLayer do
    * "../data/tiles/narodni-rada-vitezove-shaded/{z}/{x}/{y}.png"
    * zIndex: 2

for kandidat in kandidati.filter (.map)
  dataLayers[kandidat.map] = L.tileLayer do
    * "../data/tiles/narodni-rada-#{kandidat.map}/{z}/{x}/{y}.png"
    * opacity: 0.9
      zIndex: 2
currentLayer = dataLayers['winners']
  ..addTo map
infobar = new ig.Infobar container, kandidati


layers =
  * name: "Vítězové voleb"
    map: "winners"
  * name: "Vítězové (sytost podle náskoku)"
    map: "winners-amount"
layers ++= kandidati.filter (.map)

container.append \select
  ..selectAll \option .data layers .enter!append \option
    ..html (.name)
    ..attr \value (.map)
  ..on \change ->
    map.removeLayer currentLayer
    currentLayer := dataLayers[@value]
      ..addTo map
    setBackground!

setBackground = ->
  zoom = map.getZoom!
  isChoropleth = currentLayer in [winnersLayer, winnersLayerShaded]
  if not isChoropleth
    mapElement.style \background-color \black
    if zoom >= 9
      labelLayer.setOpacity 0.7
    else
      labelLayer.setOpacity 0.1
    if zoom >= 11
      baseLayer.setOpacity 1
    else
      baseLayer.setOpacity 0.2

  else
    mapElement.style \background-color \white
    baseLayer.setOpacity 0.8
    labelLayer.setOpacity 0.8
    if currentLayer is winnersLayer
      if zoom > 10
        currentLayer.setOpacity 0.4
      else
        currentLayer.setOpacity 0.7

setBackground!
map.on \zoomend setBackground

(err, text) <~ d3.text "/tools/suggester/0.0.1/okresy_obce.tsv"
[okresy, obce] = text.split "\n\n"
okresy_assoc = {}
okresy.split "\n"
  .map (.split "\t")
  .forEach ([kod, nazev]) -> okresy_assoc[kod] = {kod, nazev}
obce_assoc = {}
obce = for line in obce.split "\n"
  [lon, lat, id, okres_kod, nazev] = line.split "\t"
  okres = okresy_assoc[okres_kod]
  lat = parseFloat lat
  lon = parseFloat lon
  id = parseInt id, 10
  nazevSearchable = nazev.toLowerCase!
  obce_assoc[id] = {lat, lon, id, okres, nazev, nazevSearchable}

infobar.obce = obce_assoc

suggesterContainer = container.append \div
  ..attr \class \suggesterContainer
  ..append \span .html "Najít obec"
selectedOutline = null

setOutline = (iczuj) ->
  if selectedOutline
    map.removeLayer selectedOutline
  (err, data) <~ d3.json "/tools/suggester/0.0.1/geojsons/#{iczuj}.geo.json"
  return unless data
  style =
    fill: no
    opacity: 1
    color: '#000'
  selectedOutline := L.geoJson data, style
    ..addTo map

new ig.Suggester suggesterContainer, obce
  ..on 'selected' (obec) ->
      map.setView [obec.lat, obec.lon], 12
      setOutline obec.id



