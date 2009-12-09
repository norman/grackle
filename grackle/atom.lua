module("grackle.atom", package.seeall)

TEMPLATE = [=[
!!! xml utf-8
%feed(xml:lang=feed.lang xmlns="http://www.w3.org/2005/Atom")
  %id= feed.id
  - if feed.generator then
    %generator(format="html")
      &= feed.generator
  %link(href=feed.uri type="application/atom+xml" rel="self")
  %link(href=feed.alternate_uri type="text/html" rel="alternate")
  %title(type="html")
    &= feed.title
  %subtitle(type="html")
    &= feed.subtitle
  %updated= rfc3339(feed.updated)
  - if feed.rights then
    %rights(type="html")
      &= feed.rights
  - if feed.author then
    %author
      %name= feed.author.name
      - if feed.author.email then
        %email= feed.author.email
      - if feed.author.uri then
        %uri=feed.author.uri
  - for c in ipairs(feed.contributors or {}) do
    %contributor
      %name= c.name
      - if c.email then
        %email= c.email
      - if c.uri then
        %uri= c.uri
  - for _, entry in ipairs(feed.entries) do
    %entry
      %title(type="html")
        &= entry.title
      %id= entry.id
      %link(href=entry.uri)
      %published= rfc3339(entry.published)
      - if entry.updated then
        %updated= rfc3339(entry.updated)
      %author
        %name= entry.author.name
        - if entry.author.email then
          %email= entry.author.email
        - if entry.author.uri then
          %uri= entry.author.uri
      - for c in ipairs(entry.contributors or {}) do
        %contributor
          %name= c.name
          - if c.email then
            %email= c.email
          - if c.uri then
            %uri= c.uri
      - if entry.summary then
        %summary(type="html")=
        &= yield(entry.summary)
      %content(type="html")
        &= yield(entry.content)
]=]

function taguri(uri, date)
  local tagdate = date and string.format("%s-%s-%s", date.year, date.month, date.day) or "2009"
  local s = uri:gsub("^.*://", "tag:"):gsub("#", "/")
  return (s:gsub("(.-)/(.*)", "%1," .. tagdate .. ":/%2"))
end

