module("Page", package.seeall)
setmetatable(Page, {__index = grackle})

function new(template)

  local p = {}
  local t = template
  setmetatable(p, {__index = _M })
  local locals = {site = grackle.site_config, page = t.page_config}
  local success, result = pcall(grackle.render, t:get_renderer(), t:get_contents(), locals)
  if not success then
    error("Could not render page " .. t.path .. ": " .. result)
  end

  p.content = result
  p.title = t:get_title()
  p.path = '/' .. t:get_site_path():gsub("^/", "")
  p.uri = grackle.site_config.uri:gsub("/$", "") .. p.path
  p.published = "1970-01-01" -- default, will be overidden if set

  if t.page_config and t.page_config.published then
    p.published = t.page_config.published and t.page_config.published
    p.updated = t.page_config.updated and t.page_config.updated or p.published
    p.feed = t:get_dir_name()
    p.author = t.page_config.author or grackle.site_config.author
    p.categories = t.page_config.categories or {}
    p.contributors = t.page_config.contributors or {}
    p.id = t.page_config.id or grackle.atom.taguri(p.uri, p.published:to_date())
    if type(t.page_config.summary) == "function" then
      p.summary = t.page_config.summary(p.content)
    else
      p.summary = t.page_config.summary
    end
  end

  return p

end

function Page:is_entry()
  return not not self.feed
end
