module("util", package.seeall)

function lfs.mkdir_p(path)
  local current
  for dir in string.split(path, grackle.PATH_SEPARATOR) do
    if not current then
      current = dir
    else
      current = util.path(current, dir)
    end
    lfs.mkdir(current)
  end
end

function string:title_case()
  return (self:gsub("^%a", string.upper):gsub("%s+%a", string.upper))
end

function string:to_date()
  local date = {}
  date.year, date.month, date.day, date.hour, date.min, date.sec =
    self:match("(%d*)%-(%d*)%-(%d*)%s?(%d*):?(%d*):?(%d*)")
  if date.hour == "" then date.hour = "00" end
  if date.min == "" then date.min = "00" end
  if date.sec == "" then date.sec = "00" end
  return date
end

function string:split(pat)
  local st, g = 1, self:gmatch("()("..pat..")")
  local function getter(self, segs, seps, sep, cap1, ...)
    st = sep and seps + #sep
    return self:sub(segs, (seps or 0) - 1), cap1 or sep, ...
  end
  local function splitter(self)
    if st then return getter(self, st, g()) end
  end
  return splitter, self
end

function in_table(t, item)
  for i, v in ipairs(t) do
    if item == v then return true end
  end
  return false
end

--- Naive, shallow tables merge.
function merge_tables(...)
  local merged = {}
  for _, t in ipairs {...} do
    for k, v in pairs(t) do
      merged[k] = v
    end
  end
  return merged
end

function path(...)
  return table.concat({...}, grackle.PATH_SEPARATOR)
end

function print(...)
  local buf = {}
  local seen = {}
  for _, v in ipairs({...}) do
    if type(v) == "table" and not seen[v] then
      seen[v] = true
      table.insert(buf, render_table(v))
    else
      table.insert(buf, tostring(v))
    end
  end
  _G["print"](unpack(buf))
end

function table.first(t, func)
  for _, t in ipairs(t) do
    if func(t) then return t end
  end
end

function table.each(t, func)
  local func = func or function() return true end
  return coroutine.wrap(function()
    (function()
      for _, v in ipairs(t) do
        if func(v) then coroutine.yield(v) end
      end
    end)()
  end)
end

function render_table(t)
  local buf = {}
  for k, v in pairs(t) do
    local content
    if type(v) == "table" then
      content = render_table(v)
    elseif type(v) == "string" then
      content = '"' .. v .. '"'
    else
      content = tostring(v)
    end
    table.insert(buf, string.format("%s = %s", tostring(k), tostring(content)))
  end
  return string.format("{%s}", table.concat(buf, ", "))
end

function strip(str)
  return (str:gsub("^%s*", ""):gsub("%s*$", ""))
end

function ltrimdir(path)
  return (path:gsub("^[^/]*/?", ""))
end

