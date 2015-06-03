lineHeight = 40
percentage = -> "#{window.ig.utils.formatNumber it * 100}&nbsp;%"
class ig.Infobar
  (@parentElement, @kandidati) ->
    @kandidatiUnsorted = @kandidati.slice!
    @element = @parentElement.append \div
      ..attr \class \infobar
    @init!

  displayData: ({nazev, volicu, obalek, strany}:data) ->
    if @obce
      @nazev.text nazev
    for party, index in @kandidatiUnsorted
      party.votes = strany[index]
      party.percent = party.votes / volicu
    @kandidati.sort (a, b) -> b.votes - a.votes
    for party, index in @kandidati
      party.index = index
      # party.width = party.votes / @kandidati.0.votes

    @element.classed \noData !volicu
    if !volicu
      @helpText.html "Bohužel, pro tuto obec nemáme k dispozici data"
    else
      @helpText.html ""
    @strany.style \top -> "#{it.index * lineHeight}px"
    @stranyPercent.html ->
      if it.nesestavila
        "Nikdo nekandidoval"
      else
        "#{percentage it.percent}"
    @stranyHlasu.html -> "#{it.votes} hl."
    @stranyBar.style \width -> "#{it.percent * 270}px"

  reInit: ->
    @nazev.text "Mapa výsledků"
    @helpText.html "Bohužel, pro tuto obec nemáme k dispozici data"
    @stranyHlasu.html ""
    @stranyPercent.html ""
    @stranyBar.style \width "0px"


  init:  ->
    @nazev = @element.append \h2
      ..text "Mapa výsledků"
    @helpText = @element.append \span
      ..attr \class \clickInvite
      ..text "Výsledky voleb v okrsku zobrazíte najetím na okrsek v mapě"
    stranyCont = @element.append \ul
      ..attr \class \strany-cont

    @strany = stranyCont.selectAll \li .data @kandidati .enter!append \li
      ..attr \class \strana
      ..style \top (d, i) -> "#{i * lineHeight}px"
      ..append \span
        ..attr \class \nazev
        ..html (.name)
      ..append \span
        ..attr \class \hlasu
        ..append \span
          ..attr \class \absolute
        ..append \span
          ..attr \class \relative
      ..append \div
        ..attr \class \bar
        ..style \background-color (.color)
      ..append \div
        ..attr \class \kost
        ..style \background-color (.color)
    @stranyPercent = @strany.selectAll \.relative
    @stranyHlasu = @strany.selectAll \.absolute
    @stranyBar = @strany.selectAll \.bar
