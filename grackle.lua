module("grackle", package.seeall)

require "lfs"
require "haml"
require "markdown"
require "cosmo"

require "grackle.util"
require "grackle.helpers"
require "grackle.atom"


HEADER_PATTERN   = "^%-%-%-(.*)%-%-%-%s*"
LAYOUTS_DIR      = "layouts"
OUTPUT_DIR       = "site"
PAGES_DIR        = "pages"
PARTIALS_DIR     = "partials"
PATH_SEPARATOR   = "/"
DEFAULT_RENDERER = "haml"
DEFAULT_LAYOUT   = util.path(LAYOUTS_DIR, "main.html." .. DEFAULT_RENDERER)
RENDERERS        = { "haml", "markdown", "cosmo" }
LAYOUT_RENDERERS = { "haml", "cosmo" }
HAML_OPTIONS     = {
  format = "html5"
}

require "grackle.template"

feeds       = nil
main_layout = nil
site_config = nil
source_dir  = nil
templates   = nil

function generate_site(dir)
  grackle.init(dir)
  for t in table.each(grackle.templates, Template.is_content) do
    lfs.mkdir_p(util.path(grackle.OUTPUT_DIR, t:get_site_dir()))
    local file = io.open(util.path(grackle.OUTPUT_DIR, t:get_site_path()), "w")
    local output = grackle.render(t)
    file:write(output)
    file:close()
  end
  local feeds = grackle.atom.get_feeds()
  for name, feed in pairs(feeds) do
    local file = io.open(util.path(grackle.OUTPUT_DIR, name .. ".atom"), "w")
    file:write(feed)
    file:close()
  end
end

function init(source_dir)
  grackle.source_dir = source_dir
  templates = get_templates(source_dir)
  main_layout = table.first(templates, Template.is_main_layout)
 	site_config = main_layout:eval_headers()
	feeds = grackle.atom.load_feed_data()
end

function render_template(format, str, locals)
  local locals = locals or {}
  if format == "haml" then
    setmetatable(locals, {__index = grackle.helpers})
    return haml.render(str, grackle.HAML_OPTIONS, locals)
  elseif format == "markdown" then
    return markdown(str)
  elseif format == "cosmo" then
    return cosmo.fill(str, locals)
  end
end

function render(t, locals)
  t:eval_headers()
  local locals = locals or {site = {}, page = {}}
  local layout = t:get_layout()
  locals.site = grackle.site_config
  locals.page = util.merge_tables(locals.page, t.page_config)
  local rendered = render_template(t:get_renderer(), t:get_contents(), locals)
  if not layout then
    return rendered
  else
    locals.content = rendered
    return render(layout, locals)
  end
end

--- Gets a list of files to use for building the site
function get_templates(dir)
  local stack = {}
  local files = {}
  table.insert(stack, dir)
  while #stack > 0 do
    local cwd = table.remove(stack)
    for file in lfs.dir(cwd) do
      if file ~= "." and file ~= ".." then
        local path = string.format("%s/%s", cwd, file)
        local attr = lfs.attributes(path)
        if attr.mode == "directory" then
          table.insert(stack, path)
        else
          table.insert(files, Template.new {path = path})
        end
      end
    end
  end
  return files
end
