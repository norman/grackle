module("grackle.atom", package.seeall)

template = [=[
- lang = site.lang or "en"
!!! xml utf-8
%feed(xml:lang=lang xmlns="http://www.w3.org/2005/Atom")
  %id= site.link
  %link(href=feed.link type="application/atom+xml" rel="self")
  %link(href=site.link type="text/html" rel="alternate")
  %title
    &= site.title
  %updated= feed.updated
  %subtitle(type="html")
    &= site.subtitle
  %author
    %name= site.author
    %email= site.email
  - for _, e in ipairs(feed.entries) do
    %entry
      %title(type="html")
        &= e.title
      %id= e.link
      %link(href=e.link)
      %published= e.published_at
      %updated= e.published_at
      - if e.summary then
        %summary(type="html")=
        &= yield(e.summary)
      %content(type="html")
        &= yield(e.content)
]=]

function load_feed_data()
	local feeds = {}
  for t in table.each(grackle.templates, Template.is_content) do
    t:eval_headers()
    if t.page_config.title and t.page_config.published_at then
      local name = t:get_dir_name()
      if not feeds[name] then feeds[name] = {} end
      table.insert(feeds[name], t)
    end
  end
  for _, f in ipairs(feeds) do
    table.sort(f, function(a, b)
      return os.time(a.published_at:to_date()) < os.time(b.published_at:to_date())
    end)
  end
  return feeds
end

function get_feeds()
	local rendered_feeds = {}
	for name, feed in pairs(grackle.feeds) do
		local entries = {}
		for i, t in ipairs(feed) do
			t:eval_headers()
			local content = grackle.render_template(t:get_renderer(), t:get_contents(), {site = grackle.site_config, page = t.page_config})
			table.insert(entries, {
				title = t.page_config.title,
				link = grackle.site_config.link .. '/' .. t:get_site_path(),
				published_at = t.page_config.published_at:rfc3339(),
				content = content
			})
		end
		local haml_config = {format = "xhtml"}
		local locals = {
			site = grackle.site_config,
			feed = {
        updated = entries[1].published_at,
				link = grackle.site_config.link .. '/' .. name .. ".atom",
				entries = entries
			}
		}
		rendered_feeds[name] = haml.render(grackle.atom.template, haml_config, locals)
	end
	return rendered_feeds
end
