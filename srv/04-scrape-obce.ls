require! {
  fs
  request
  async
}

links = fs.readFileSync "#__dirname/../data/fed/obce.txt" .toString!split "\n"
  ..pop!
i = 0
async.eachSeries links, (link, cb) ->
  console.log i++
  obecId = link.split "=" .pop!
  (err, response, body) <~ request url: "http://volby.cz/pls/sl1990/#link" gzip: yes, encoding: null
  <~ fs.writeFile "#__dirname/../data/fed/obce/#obecId.html", body
  setTimeout cb, 500
