module("grackle.helpers", package.seeall)

function link(name, href, options)
  local buf = {}
  for k, v in pairs(options or {}) do
    table.insert(buf, string.format('%s="%s"', tostring(k), tostring(v)))
  end
  table.insert(buf, string.format('href="%s"', href))
  table.sort(buf)
  return string.format('<a %s>%s</a>', table.concat(buf, " "), name)
end

function taguri(uri, date)
  local tagdate = date and string.format("%s-%s-%s", date.year, date.month, date.day) or "2009"
  local s = uri:gsub("^.*://", "tag:"):gsub("#", "/")
  return (s:gsub("(.-)/(.*)", "%1," .. tagdate .. ":/%2"))
end

function rfc3339(str)
  local date = str:to_date()
  return string.format(
    "%s-%s-%sT%s:%s:%sZ",
    date.year,
    date.month,
    date.day,
    date.hour,
    date.min,
    date.sec
  )
end
