require! {
  fs
  request
  async
}

links = fs.readFileSync "#__dirname/../data/ucelky/okresy.txt" .toString!split "\n"
i = 0
async.eachSeries links, (link, cb) ->
  ii = i++
  console.log ii
  (err, response, body) <~ request url: "http://volby.cz/pls/sn1990/#link" gzip: yes, encoding: null
  cb!
  fs.writeFile "#__dirname/../data/ucelky/okresy/#ii.html", body
