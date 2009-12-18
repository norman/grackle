module("grackle", package.seeall)

require "lfs"
require "haml"
require "markdown"
require "cosmo"

require "grackle.helpers"
require "grackle.util"
require "grackle.atom"

VERSION          = {0, 1, 0}
VERSION_STRING   = table.concat(VERSION, ".")
GENERATOR_STRING = 'Grackle %s' .. VERSION_STRING
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
require "grackle.page"

feeds       = {}
main_layout = nil
pages       = {}
site_config = nil
source_dir  = nil
templates   = {}

function generate_site(dir)
  grackle.init(dir)
  for t in table.each(grackle.templates, Template.is_content) do
    lfs.mkdir_p(util.path(grackle.OUTPUT_DIR, t:get_site_dir()))
    local file, err = io.open(util.path(grackle.OUTPUT_DIR, t:get_site_path()), "w")
    if not file then error(err) end
    assert(file:write(render_with_layout(t)))
    file:close()
  end
  for name, feed in pairs(feeds) do
    local file = io.open(util.path(grackle.OUTPUT_DIR, name .. ".atom"), "w")
    local output = render("haml", grackle.atom.TEMPLATE, {feed = feed}, {format = "xhtml"})
    file:write(output)
    file:close()
  end
end

--- Parse all the files and load the data into Grackle in preparation for
-- writing the site files.
function init(source_dir)
  grackle.source_dir = source_dir
  templates = get_templates(source_dir)
  main_layout = table.first(templates, Template.is_main_layout)
 	site_config = main_layout.site_config
  -- some people will find "uri" confusing, so support some aliases
  if not site_config.uri then
    site_config.uri = site_config.link or site_config.url
  end
  for t in table.each(grackle.templates, Template.is_content) do
    table.insert(pages, t:to_page())
  end
  feeds = get_feeds(pages)
  site_config.feeds = feeds
end

--- Renders the content of a template.
-- @param renderer The renderer to use.
-- @param str The template string. This should be the template contents, not a path
-- to a file.
-- @param locals A table of local variables to use in the template.
-- @param options A table of options to pass into the renderer (if the renderer
-- supports them).
function render(renderer, str, locals, options)
  local locals = locals or {}
  local options = options or {}
  if renderer == "haml" then
    setmetatable(locals, {__index = grackle.helpers})
    return haml.render(str, util.merge_tables(grackle.HAML_OPTIONS, options), locals)
  elseif renderer == "markdown" then
    return markdown(str)
  elseif renderer == "cosmo" then
    return cosmo.fill(str, locals)
  end
end

--- Renders a layout with its template.
-- This does the final rendering suitable for writing the file to disk.
-- @param template The template, an instance of the Template class
-- @param locals Local variables to be used in the template.
function render_with_layout(template, locals)
  local t = template
  local locals = locals or {site = {}, page = {}}
  local layout = t:get_layout()
  locals.site = grackle.site_config
  locals.page = util.merge_tables(locals.page, t.page_config)
  if not locals.my then locals.my = t:to_page() end
  local options = {file = template.path}
  if t:get_renderer() == "haml" and t:get_format() == "xml" then
    options.format = "xhtml"
  end
  local rendered = render(t:get_renderer(), t:get_contents(), locals, options)
  if not layout then
    return rendered
  else
    locals.content = rendered
    return render_with_layout(layout, locals)
  end
end

--- Gets a list of files to use for building the site
function get_templates(dir)
  local templates = {}
  local stack = {}
  table.insert(stack, dir)
  while #stack > 0 do
    local cwd = table.remove(stack)
    for file in lfs.dir(cwd) do
      local path = string.format("%s/%s", cwd, file)
      local attr = lfs.attributes(path)
      if attr.mode == "directory" and file ~= "." and file ~= ".." then
        table.insert(stack, path)
      elseif not file:match("^%.") then -- skip hidden files on Unix
        table.insert(templates, Template.new {path = path})
      end
    end
  end
  return templates
end

function get_feeds(pages)
  local feeds = {}
  table.sort(pages, function(a, b)
    return os.time(a.published:to_date()) > os.time(b.published:to_date())
  end)
  for page in table.each(pages, Page.is_entry) do
    if not feeds[page.feed] then feeds[page.feed] = {entries = {}} end
    table.insert(feeds[page.feed].entries, page)
  end
  for name, feed in pairs(feeds) do
    feed.generator = GENERATOR_STRING
    feed.lang = site_config.lang or "en"
    feed.uri = site_config.uri:gsub("/$", "") .. '/' .. name .. ".atom"
    feed.alternate_uri = site_config.uri
    feed.id = grackle.atom.taguri(feed.uri)
    feed.title = site_config.title
    feed.subtitle = site_config.subtitle
    feed.updated = feed.entries[1].updated or feed.entries[1].published
    feed.author = site_config.author
    feed.rights = site_config.rights
    feed.categories = get_feed_categories(feed)
  end
  return feeds
end

function get_feed_categories(...)
  local categories = {}
  local buffer = {}
  for _, feed in ipairs({...}) do
    for _, entry in ipairs(feed.entries) do
      if entry.categories then
        for _, category in ipairs(entry.categories) do
          if not buffer[category] then
            buffer[category] = {name = category, pages = {entry}}
          else
            table.insert(buffer[category].pages, entry)
          end
        end
      end
    end
  end
  for _, category in pairs(buffer) do
    table.insert(categories, category)
  end
  table.sort(categories, function(a, b)
    if #a.pages == #b.pages then
      return a.name < b.name
    else
      return #a.pages > #b.pages
    end
  end)
  return categories
end
