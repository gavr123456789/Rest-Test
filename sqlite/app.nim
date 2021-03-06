from sqlite3 import last_insert_rowid
# import print
import std/jsonutils
import 
    strutils, 
    db_sqlite, 
    prologue,
    views, 
    json
    


# Create instance
var app = newApp()


# http://0.0.0.0:8080/getAll
app.get("/getAll", proc(ctx: Context) {.async.} =
    let db = open("sqlite.db", "", "", "")
    let query = sql("""SELECT * FROM todo""")
    let rows = db.getAllRows(query)


    # var cols : DbColumns = @[]
    # for x in db.instantRows(cols, query):
    #     for idx, col in cols:
    #         echo col.name, ": ", col

    var columns: DbColumns
    for row in db.instantRows(columns, query):
        discard
    echo columns[0]
    db.close()


    # echo rows
    
    # resp htmlResponse(listView(rows=rows))
    resp jsonResponse(rows.toJson)
)

# - create
app.get("/create", proc(ctx: Context) {.async.} =
    if ctx.getQueryParams("save").len != 0:
        let
            row = ctx.getQueryParams("task").strip
            db = open("sqlite.db", "", "", "")
        db.exec(sql"INSERT INTO todo (task,status) VALUES (?,?)", row, 1)
        let
            id = last_insert_rowid(db)
        db.close()
        resp redirect("/create/?status=success&id=" & $id)
    else:
        resp htmlResponse(createView(ctx.getQueryParams("status"), ctx.getQueryParams("id")))
)

# - read
app.get("/read/{item}", proc(ctx: Context) {.async.} =
    let
        db = open("sqlite.db", "", "", "")
        item = ctx.getPathParams("item", "")
        rows = db.getAllRows(sql"SELECT task FROM todo WHERE id LIKE ?", item)
    db.close()
    if rows.len == 0:
            resp "This item number does not exist!"
    else:
            resp htmlResponse(readView($rows[0]))
)

# - update
app.get("/update/{id}", proc(ctx: Context) {.async.} =
    if ctx.getQueryParams("save").len != 0:
        let
            edit = ctx.getQueryParams("task").strip
            status = ctx.getQueryParams("status").strip
            id = ctx.getPathParams("id", "")
        var statusId = 0
        if status == "open":
                statusId = 1
        let db= open("sqlite.db", "", "", "")
        db.exec(sql"UPDATE todo SET task = ?, status = ? WHERE id LIKE ?", edit, statusId, id)
        db.close()
        resp redirect("/update/" & id & "?status=success")
    else:
        let db = open("sqlite.db", "", "", "")
        let id = ctx.getPathParams("id", "")
        let data = db.getAllRows(sql"SELECT task FROM todo WHERE id LIKE ?", id)
        db.close()
        resp htmlResponse(updateView(id.parseInt, data[0], ctx.getQueryParams("status")))
)

# - delete
app.get("/delete/{id}", proc(ctx: Context) {.async.} =
    let
        id = ctx.getPathParams("id")
        db= open("sqlite.db", "", "", "")

    db.exec(sql"DELETE FROM todo WHERE id = ?", id)
    db.close()
    resp redirect("/")
)

# Run instance
app.run()
