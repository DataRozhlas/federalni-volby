require! {
  fs
  jsdom:{env}
  async
}
okresy = fs.readdirSync "#__dirname/../data/ucelky/obce"
okresy .= slice 2160
outStream = fs.createWriteStream "#__dirname/../data/ucelky/vyledky2.tsv"
i = 0
columns = <[obec volici 03 04 06 08 08 09 10 11 13 18 19 20 21 22 23]>
outStream.write columns.join "\t"
async.eachSeries okresy, (file, cb) ->
  console.log i++
  obecId = file.split "." .0
  data = fs.readFileSync "#__dirname/../data/ucelky/obce/#file" .toString!
  line = columns.map (d, i) -> if i then 0 else obecId
  (err, {document}:window) <~ env data
  rows = document.querySelectorAll "table:nth-of-type(2) tr"
  line[1] = document.querySelector "table:nth-of-type(1) tr:nth-child(3) td:nth-child(4)" .innerHTML
    .replace /&nbsp;/g ''
  for row, index in rows
    continue if index <= 1
    id1 = row.querySelector "td:nth-child(1) a"
    continue unless id1
    position1 = columns.indexOf id1.innerHTML
    count1 = row.querySelector "td:nth-child(3)"
      .innerHTML
      .replace '&nbsp;' ''
    line[position1] = count1

    id2 = row.querySelector "td:nth-child(6) a"
    continue unless id2
    position2 = columns.indexOf id2.innerHTML
    count2 = row.querySelector "td:nth-child(8)"
      .innerHTML
      .replace '&nbsp;' ''
    line[position2] = count2
  <~ outStream.write ("\n" + line.join "\t")
  cb!
