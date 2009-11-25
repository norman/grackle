require "grackle"

context("Content files using a non-default renderer", function()

  local template

  setup(function()
    grackle.source_dir = 't'
    grackle.templates = {
      Template.new { path = "t/layouts/main.css.cosmo", file = "" },
      Template.new { path = "t/layouts/main.html.haml", file = "" },
      Template.new { path = "t/layouts/posts.html.haml", file = "---\npage.layout = 'main'\n---\n" },
      Template.new { path = "t/pages/stylesheets/screen.css.cosmo", file = "" },
      Template.new { path = "t/pages/index.haml", file = "" },
      Template.new { path = "t/pages/posts/first_post.markdown", file = "" },
      Template.new { path = "t/pages/stylesheets/reset.css.cosmo", file = "---\npage.layout = false\n---\n" },
    }
  end)

  test("the main layout should not have a layout", function()
    template = grackle.templates[2]
    assert_nil(template:get_layout())
  end)

  test("file using Cosmo and a main layout", function()
    template = grackle.templates[4]
    assert_equal("cosmo", template:get_layout_renderer())
    assert_equal("layouts/main.css.cosmo", template:get_layout():get_path())
  end)

  test("file using Haml and a main layout", function()
    template = grackle.templates[5]
    assert_equal("haml", template:get_layout_renderer())
    assert_equal("layouts/main.html.haml", template:get_layout():get_path())
  end)

  test("file using Markdown and a custom layout", function()
    template = grackle.templates[6]
    assert_equal("haml", template:get_layout_renderer())
    assert_equal("layouts/posts.html.haml", template:get_layout():get_path())
  end)

  test("file using Cosmo and no layout", function()
    template = grackle.templates[7]
    assert_equal("cosmo", template:get_layout_renderer())
    assert_nil(template:get_layout())
  end)

  test("a sub-layout using Haml", function()
    template = grackle.templates[3]
    assert_equal("haml", template:get_layout_renderer())
    assert_equal("layouts/main.html.haml", template:get_layout():get_path())
  end)

end)
