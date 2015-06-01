require! {
  jsdom:{env}
  request
  fs
}

# (err, response, body) <~ request url: "http://volby.cz/pls/sl1990/u53" gzip: yes, encoding: null
# <~ fs.writeFile "#__dirname/../data/fed/kraje.html", body
data = fs.readFileSync "#__dirname/../data/fed/kraje.html"
  .toString!
(err, window) <~ env data

links = window.document.querySelectorAll "table tbody tr td:last-child a"
out = for link in links
  continue unless link.innerHTML.0 is "X"
  link.getAttribute \href
fs.writeFileSync "#__dirname/../data/fed/okresy.txt" out.join "\n"
