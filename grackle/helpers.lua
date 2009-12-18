module("grackle.helpers", package.seeall)

--- Create an HTML <a> tag.
-- @param name The tag content
-- @param href The path or uri to link to
-- @param attributes A table of tag attrbitues
-- @usage link("Home", "/index.html", {id = "home" class = "nav"})
function link(content, href, attributes)
  local buf = {}
  for k, v in pairs(options or {}) do
    table.insert(buf, string.format('%s="%s"', tostring(k), tostring(v)))
  end
  table.insert(buf, string.format('href="%s"', href))
  table.sort(buf)
  return string.format('<a %s>%s</a>', table.concat(buf, " "), content)
end

--- Create a <a href="http://diveintomark.org/archives/2004/05/28/howto-atom-id">taguri</a>.
-- A taguri is an easy-to-generate globally unique id, suitable for use in an Atom feed.
-- @param uri The uri
-- @param date A Lua <a href="http://www.lua.org/manual/5.1/manual.html#pdf-os.date">date table</a>.
function taguri(uri, date)
  local tagdate = date and string.format("%s-%s-%s", date.year, date.month, date.day) or "2009"
  local s = uri:gsub("^.*://", "tag:"):gsub("#", "/")
  return (s:gsub("(.-)/(.*)", "%1," .. tagdate .. ":/%2"))
end

--- An REF3339-formatted date.
-- This is the date formated used by Atom feeds.
-- @param str The data to format.
function rfc3339(str)
  assert(type(str) == "string", "date is " .. type(str) .. ", expecting string")
  return os.date("%Y-%m-%dT%H:%M:%SZ", os.time(str:to_date()))
end

--- Extracts the first paragraph from an HTML string.
-- @param content HTML-formatted text
function first_paragraph(content)
  return (content:match("<p>(.-)</p>"))
end
