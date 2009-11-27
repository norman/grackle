This is an in-progress static website/blog generator.

Don't use it yet. I'm not done.

In lieu of documentation, for now here are a couple of relavant points:

* Implemented in Lua.
* Heavily oriented around convention over configuration.
* Templates can be Cosmo, Haml, Markdown, and others to come.
* All files can have arbitrary Lua header blocks to set up local template
  variables, or do pretty much whatever you want.
* Will come with some helpers for building common tags, doing pagination, etc.
* Will come with a scaffold generator to create common types of sites.
* Will support sites with any number of different types of syndicated content / feeds.
* Will support building large colletions of similar pages out of an SQLite database.
* Global configuration is done via headers in the main layout file; there's no
  "config" file.

In the mean time, if you want to see what this does, take a look at the files
in the sample directory and the output of running the tests:

    ------------------------------------------------------------------------
    The Grackle app:
    can load a directory of template files                               [P]
    performs initialization tasks                                        [P]
    generates the site                                                   [P]
    ------------------------------------------------------------------------
    ------------------------------------------------------------------------
    Grackle templates:
    have a base name                                                     [P]
    have a format, defaulting to 'html'                                  [P]
    have a renderer taken from the file extension                        [P]
    have a layout renderer                                               [P]
    have a dir name matching its relative location on disk               [P]
    have a site_dir matching its relative target location on disk        [P]
    have a site_path matching target file name and relative uri          [P]
    have a path matching their location relative to the source dir       [P]
    have contents                                                        [P]
    have headers                                                         [P]
    can evaluate their headers                                           [P]
    a content template:
      specifies that it is content                                       [P]
      should default to a main layout matching its renderer              [P]
      if Markdown, should use the default layout renderer                [P]
      can use headers to specify layout-less rendering                   [P]
      for rendering:
        can be Cosmo                                                     [P]
        can be Haml                                                      [P]
        can be Markdown                                                  [P]
    a layout template:
      specifes that it is a layout                                       [P]
      can be a sub-layout                                                [P]
      should not have a layout if it is a main layout                    [P]
      for rendering:
        can be Cosmo                                                     [P]
        can be Haml                                                      [P]
    a partial template:
      specifes that it is a partial                                      [P]
    ------------------------------------------------------------------------
    27 tests 27 passed 35 assertions 0 failed 0 errors 0 unassertive 0 pending
