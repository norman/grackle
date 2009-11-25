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

