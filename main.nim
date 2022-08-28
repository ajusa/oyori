import jester, asyncdispatch, nimja, sugar, strutils, os
import database

const templates = getScriptDir() / "templates"

proc isBare(request: Request): bool =
  not request.headers.hasKey("hx-boosted") and request.headers.hasKey("hx-request")

template respHtmx*(body: string): untyped {.dirty.} =
  var content {.inject.} = body
  resp tmplf(templates / "html.twig")

routes:
  get "/":
    respHtmx "<h2>Welcome to Oyori!</h2>"
  get "/donate":
    respHtmx tmplf(templates / "donate.twig")
  get "/manga":
    let after = request.params.getOrDefault("after", "0").parseInt
    let mangas = @[Manga()].dup db.select("title LIKE ? AND id > ? limit 10", "%" & @"text" & "%", after)
    respHtmx tmplf(templates / "manga" / "list.twig")
  get "/manga/@id":
    let manga = Manga().dup db.select("id = ?", @"id")
    respHtmx tmplf(templates / "manga" / "detail.twig")
  get "/post":
    let after = request.params.getOrDefault("after", $int.high).parseInt
    let posts = @[Post()].dup db.select("id < ? order by id desc limit 10", after)
    respHtmx tmplf(templates / "post" / "list.twig")
