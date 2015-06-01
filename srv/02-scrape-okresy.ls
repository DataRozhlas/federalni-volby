require! {
  fs
  request
  async
}

links = fs.readFileSync "#__dirname/../data/narada/okresy.txt" .toString!split "\n"
i = 0
async.eachSeries links, (link, cb) ->
  ii = i++
  console.log ii
  (err, response, body) <~ request url: "http://volby.cz/pls/cnr1990/#link" gzip: yes, encoding: null
  cb!
  fs.writeFile "#__dirname/../data/narada/okresy/#ii.html", body
