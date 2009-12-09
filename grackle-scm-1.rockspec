package = "grackle"
version = "scm-1"
source = {
   url = "git://github.com/norman/grackle.git",
}
description = {
   summary = "A static blog generator.",
   detailed = [[
    Generates a blog that consists entirely of HTML and Atom pages. Your templates
    can use Markdown, Cosmo or Haml.
   ]],
   license = "MIT/X11",
   homepage = "http://github.com/norman/grackle"
}
dependencies = {
   "lua >= 5.1",
   "cosmo",
   "luahaml",
   "markdown"
}

build = {
  type = "none",
  install = {
    lua = {
      "grackle.lua",
      ["grackle.util"] = "grackle/util.lua",
      ["grackle.atom"] = "grackle/atom.lua",
      ["grackle.helpers"] = "grackle/helpers.lua",
      ["grackle.template"] = "grackle/template.lua"
    },
    bin = {
      ["grackle"] = "bin/grackle"
    }
  }
}
