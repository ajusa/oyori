import yaml/tojson, norm/[model, sqlite], jsony, markdown, strscans, strformat, strutils
export model, sqlite

type
  Link* = object
    name*: string
    url*: string
  Manga* = ref object of Model
    title*: string
    status*: string
    description*: string
    thumbnail*: string
    releaseGroup*: string
    nextRelease*: string
    links*: seq[Link]
  Post* = ref object of Model
    title*: string
    author*: string
    content*: string
    date*: string

const API_KEY = readFile("key.txt").strip

func dbType*(T: typedesc[seq[Link]]): string = "STRING"
func dbValue*(val: seq[Link]): DbValue = dbValue(val.toJson())
proc to*(dbVal: DbValue, T: typedesc[seq[Link]]): T = dbVal.s.fromJson(T)

proc renameHook*(v: var Manga, fieldName: var string) =
  if fieldName == "group":
    fieldName = "releaseGroup"

proc postHook*(v: var Post) =
  v.content = v.content.markdown

proc toDownloadUrl*(link: string): string =
  var fileId: string
  if link.scanf("https://drive.google.com/file/d/$*/", fileId):
    &"https://www.googleapis.com/drive/v3/files/{fileId}/?key={API_KEY}&alt=media"
  else: link

var mangas = loadToJson(readFile("mangas.yaml"))[0].toJson().fromJson(seq[Manga])
var posts = loadToJson(readFile("news.yaml"))[0].toJson().fromJson(seq[Post])

let db* = open(":memory:", "", "", "")
db.createTables(Manga())
db.createTables(Post())
db.transaction:
  for manga in mangas.mitems:
    db.insert(manga, force = true)

  for post in posts.mitems:
    db.insert(post, force = true)
