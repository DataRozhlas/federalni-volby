require! {
  fs
  request
  async
}

links = fs.readFileSync "#__dirname/../data/narada/obce.txt" .toString!split "\n"
  ..pop!
i = 0
async.eachSeries links, (link, cb) ->
  console.log i++
  obecId = link.split "=" .pop!
  (err, response, body) <~ request url: "http://volby.cz/pls/cnr1990/#link" gzip: yes, encoding: null
  <~ fs.writeFile "#__dirname/../data/narada/obce/#obecId.html", body
  cb!
  # setTimeout cb, 500
