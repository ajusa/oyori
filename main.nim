import jester, asyncdispatch, nimja, sugar, strutils, os, strformat
import database

const templates = getScriptDir() / "templates"

template respHtmx*(body: string): untyped {.dirty.} =
  var content {.inject.} = body
  resp tmplf(templates / "html.twig")

proc isBare(request: Request): bool =
  not request.headers.hasKey("hx-boosted") and request.headers.hasKey("hx-request")

routes:
  get "/":
    respHtmx "<h2>Welcome to Oyori!</h2>"
  get "/manga":
    if not request.isBare:
      respHtmx tmplf(templates / "manga" / "filter.twig")
    else:
      var after = request.params.getOrDefault("after", "0").parseInt
      var mangas = @[Manga()].dup db.select("title LIKE ? AND id > ? limit 10", "%" & @"text" & "%", after)
      respHtmx tmplf(templates / "manga" / "list.twig")
  get "/manga/@id":
    var manga = Manga().dup db.select("id = ?", @"id")
    respHtmx tmplf(templates / "manga" / "view.twig")
  get "/post":
    var after = request.params.getOrDefault("after", $int.high).parseInt
    var posts = @[Post()].dup db.select("id < ? order by id desc limit 10", after)
    respHtmx tmplf(templates / "post" / "list.twig")
