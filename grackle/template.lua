module("Template", package.seeall)
setmetatable(Template, {__index = grackle})

local filename_pattern = string.format("%s([^%s]*)$", PATH_SEPARATOR, PATH_SEPARATOR)

function new(args)
  local t = {}
  setmetatable(t, {__index = _M })
  for k, v in pairs(args or {}) do
  	t[k] = v
  end
  t:eval_headers()
  return t
end

function Template:to_page()
  return Page.new(self)
end

function Template:get_file()
  if not self.file then
    local f, e = io.open(self.path, "r")
    if not f then error(e) end
    self.file = assert(f:read("*a"))
    assert(f:close())
  end
  return self.file
end

function Template:get_title()
  return self.page_config.title or (self:get_base_name():gsub("[%-_]", " "):title_case())
end

function Template:get_file_name()
  return (self.path:match(filename_pattern))
end

function Template:get_base_name()
  return (get_file_name(self):gsub("%..*$", ""))
end

function Template:get_format()
  return (self.path:match("%.(.*)%..*$")) or "html"
end

function Template:get_renderer()
  return (self.path:match("%..*%.(.*)$")) or (self.path:match("%.(.*)$"))
end

function Template:get_layout_renderer()
  local r = get_renderer(self)
  if util.in_table(LAYOUT_RENDERERS, r) then
    return r
  else
    return DEFAULT_RENDERER
  end
end

function Template:get_dir()
  return (self.path:gsub(filename_pattern, ""))
end

function Template:get_dir_name()
  local last
  for i in self:get_dir():split(PATH_SEPARATOR) do
    last = i
  end
  return last
end

function Template:is_layout()
  return not not (util.ltrimdir(self.path):match("^" .. LAYOUTS_DIR))
end

function Template:is_main_layout()
  return self.path == util.path(grackle.source_dir, DEFAULT_LAYOUT)
end

function Template:is_partial()
  return not not (util.ltrimdir(self.path):match("^" .. PARTIALS_DIR))
end

function Template:is_content()
  return not not (util.ltrimdir(self.path):match("^" .. PAGES_DIR))
end

function Template:get_site_dir()
  local dir = util.ltrimdir(get_dir(self))
  return util.ltrimdir(dir)
end

function Template:get_site_path()
  if not get_site_dir(self) then return end
  local dir = (get_site_dir(self):gsub("^" .. PAGES_DIR, OUTPUT_DIR)) ..
		PATH_SEPARATOR .. get_base_name(self) .. '.' .. tostring(get_format(self))
  return (dir:gsub("^" .. PATH_SEPARATOR, ''))
end

function Template:get_headers()
  local h = get_file(self):match(HEADER_PATTERN)
  if h then return util.strip(h) end
end

function Template:eval_headers()
  -- if self.site_config and self.page_config then
    -- return self.site_config and self.page_config
  -- end
  h = get_headers(self)
  self.site_config = {}
  self.page_config = {}
  local env = {site = self.site_config, page = self.page_config}
  if h then
    setmetatable(env, {__index = _G})
    local func = assert(loadstring(h))
    setfenv(func, env)
    func()
  end
  return self.site_config, self.page_config
end

function Template:get_contents()
  return util.strip(get_file(self):gsub(HEADER_PATTERN, ""))
end

function Template:get_path()
  return (self.path:gsub("^" .. grackle.source_dir .. PATH_SEPARATOR, ""))
end

local function get_renderer_path(dir, format, renderer)
  return util.path(LAYOUTS_DIR, dir .. '.' .. format .. '.' .. renderer)
end

function Template:get_layout()	
  if self:is_partial() then return nil end
  if self:is_layout() and self:get_base_name() == "main" then return nil end
  if self.page_config.layout == false then return nil end
  local site_dir = self:get_site_dir()
  local format = self:get_format()
  local renderer = self:get_layout_renderer()
  local default_path = get_renderer_path("main", format, renderer)
	local path = get_renderer_path(self.page_config.layout or site_dir, format, renderer)
  local layout =
    table.first(grackle.templates, function(t) return t:get_path() == path end)
      or
    table.first(grackle.templates, function(t) return t:get_path() == default_path end)
  return layout
end
