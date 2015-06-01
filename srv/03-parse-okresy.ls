require! {
  fs
  jsdom:{env}
  async
}
outStream = fs.createWriteStream "#__dirname/../data/narada/obce.txt"
okresy = fs.readdirSync "#__dirname/../data/narada/okresy" .map -> "#__dirname/../data/narada/okresy/#it"
i = 0
async.eachSeries okresy, (file, cb) ->
  console.log i++
  data = fs.readFileSync file .toString!
  (err, {document}:window) <~ env data
  links = document.querySelectorAll "table tbody tr td:nth-child(3) a"
  out = for link in links
    continue unless link.innerHTML.1 is "X"
    link.getAttribute \href
  <~ outStream.write ((out.join "\n") + "\n")
  cb!
