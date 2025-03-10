require! {
  jsdom:{env}
  request
  fs
}

# (err, response, body) <~ request url: "http://volby.cz/pls/sn1990/u53" gzip: yes, encoding: null
# <~ fs.writeFile "#__dirname/../data/ucelky/kraje.html", body
# return
data = fs.readFileSync "#__dirname/../data/ucelky/kraje.html"
  .toString!
(err, window) <~ env data

links = window.document.querySelectorAll "table tbody tr td:last-child a"
out = for link in links
  continue unless link.innerHTML.0 is "X"
  link.getAttribute \href
fs.writeFileSync "#__dirname/../data/ucelky/okresy.txt" out.join "\n"
