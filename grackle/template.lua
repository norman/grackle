module("Template", package.seeall)
setmetatable(Template, {__index = grackle})

local filename_pattern = string.format("%s([^%s]*)$", PATH_SEPARATOR, PATH_SEPARATOR)

function new(args)
  local t = {}
  setmetatable(t, {__index = _M })
  for k, v in pairs(args or {}) do
  	t[k] = v
  end
  return t
end

function get_file(self)
	if not self.file then
		self.file = io.input(self.path):read("*a")
	end
 return self.file
end

function get_file_name(self)
  return (self.path:match(filename_pattern))
end

function get_base_name(self)
  return (get_file_name(self):gsub("%..*$", ""))
end

function get_format(self)
  return (self.path:match("%.(.*)%..*$")) or "html"
end

function get_renderer(self)
  return (self.path:match("%..*%.(.*)$")) or (self.path:match("%.(.*)$"))
end

function get_layout_renderer(self)
  local r = get_renderer(self)
  if util.in_table(LAYOUT_RENDERERS, r) then
    return r
  else
    return DEFAULT_RENDERER
  end
end

function get_dir_name(self)
  return (self.path:gsub(filename_pattern, ""))
end

function is_layout(self)
  return not not (util.ltrimdir(self.path):match("^" .. LAYOUTS_DIR))
end

function is_partial(self)
  return not not (util.ltrimdir(self.path):match("^" .. PARTIALS_DIR))
end

function is_content(self)
  return not not (util.ltrimdir(self.path):match("^" .. PAGES_DIR))
end

function get_site_dir(self)
  local dir = util.ltrimdir(get_dir_name(self))
  return util.ltrimdir(dir)
end

function get_site_path(self)
  if not get_site_dir(self) then return end
  local dir = (get_site_dir(self):gsub("^" .. PAGES_DIR, OUTPUT_DIR)) ..
		PATH_SEPARATOR .. get_base_name(self) .. '.' .. tostring(get_format(self))
  return (dir:gsub("^" .. PATH_SEPARATOR, ''))
end

function get_headers(self)
  local h = get_file(self):match(HEADER_PATTERN)
  if h then return util.strip(h) end
end

function eval_headers(self)
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

function get_contents(self)
  return util.strip(get_file(self):gsub(HEADER_PATTERN, ""))
end

function get_path(self)
  return self.path:gsub("^" .. grackle.source_dir .. PATH_SEPARATOR, "")
end

local function get_renderer_path(dir, format, renderer)
  return util.path(LAYOUTS_DIR, dir .. '.' .. format .. '.' .. renderer)
end

function get_layout(self)	
  if self:is_partial() then return nil end
  if self:is_layout() and self:get_base_name() == "main" then return nil end
  self:eval_headers()
  if self.page_config.layout == false then return nil end
  local site_dir = self:get_site_dir()
  local format = self:get_format()
  local renderer = self:get_layout_renderer()
  local default_path = get_renderer_path("main", format, renderer)
	local path = get_renderer_path(site_dir, format, renderer)
  local layout =
    util.first(grackle.templates, function(t) return t:get_path() == path end)
      or
    util.first(grackle.templates, function(t) return t:get_path() == default_path end)
  return layout
end
