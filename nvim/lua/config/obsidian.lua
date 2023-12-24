require("obsidian").setup({
  workspaces = {
    {
      name = "personal",
      path = "~/Work/obsidian",
    },
    {
      name = "work",
      path = "~/Work/obsidian",
    },
  },
  daily_notes = {
    folder = "daily",
    date_format = "%Y-%m-%d",
    template = "daily.md",
  },
  templates = {
    subdir = "templates",
  },
})
