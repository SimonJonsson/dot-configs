-- Centre a lone code window on the ultrawide: empty side buffers pad it, shrink
-- as splits are opened, and drop out once there is no room.
--
-- The width scales with the terminal instead of being fixed, because AeroSpace
-- already pads the window on the DELL (outer gaps in aerospace.toml): a fixed
-- width that suits a full-width terminal wastes space in the padded one.
local RATIO = 0.75 -- share of the terminal width given to the code window
local MIN_WIDTH = 180 -- never narrower than this; at or below it there is no padding

local function width()
  return math.max(MIN_WIDTH, math.floor(vim.o.columns * RATIO))
end

local function enabled()
  return _G.NoNeckPain and _G.NoNeckPain.state and _G.NoNeckPain.state.enabled
end

return {
  "shortcuts/no-neck-pain.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<leader>uN",
      function()
        require("no-neck-pain").toggle()
        -- Remember a manual "off" so opening the next file doesn't undo it.
        vim.g.no_neck_pain_off = not enabled()
      end,
      desc = "Toggle centred layout",
    },
  },
  opts = function()
    return { width = width() }
  end,
  config = function(_, opts)
    require("no-neck-pain").setup(opts)

    -- Enable on the first real file rather than on VimEnter: the side buffers
    -- would otherwise replace LazyVim's dashboard (and its session restore).
    local function maybe_enable(buf)
      -- aporia's sidebar pauses the padding and resumes it when it closes
      if vim.g.no_neck_pain_off or vim.g.aporia_sidebar or enabled() then
        return
      end
      if vim.bo[buf].buftype ~= "" or vim.api.nvim_buf_get_name(buf) == "" then
        return
      end
      vim.schedule(function()
        require("no-neck-pain").enable()
      end)
    end
    vim.api.nvim_create_autocmd("BufWinEnter", {
      callback = function(ev)
        maybe_enable(ev.buf)
      end,
    })
    -- `nvim <file>` shows the file before VeryLazy loads this plugin.
    maybe_enable(vim.api.nvim_get_current_buf())

    -- no-neck-pain only hides the split lines next to its padding for opaque
    -- themes; with the transparent tokyonight they stay. A vertical separator
    -- is drawn by the window on its left, so blank it on every window that is
    -- padding or has padding to its right; separators between code windows stay.
    local function is_pad(win)
      return vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "no-neck-pain"
    end
    local function update_separators()
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_get_config(win).relative == "" then
          local right = vim.fn.win_getid(vim.api.nvim_win_call(win, function()
            return vim.fn.winnr("l")
          end))
          -- Padding windows are empty buffers, so also blank their `~` filler.
          local fill = ""
          if is_pad(win) then
            fill = "vert: ,eob: "
          elseif right ~= win and is_pad(right) then
            fill = "vert: "
          end
          -- Local scope only (vim.wo would also change the global value);
          -- an empty local value falls back to the global fillchars.
          vim.api.nvim_set_option_value("fillchars", fill, { scope = "local", win = win })
        end
      end
    end
    vim.api.nvim_create_autocmd({ "WinNew", "WinClosed", "WinResized", "BufWinEnter", "TabEnter" }, {
      callback = function()
        vim.schedule(update_separators)
      end,
    })

    -- Keep the ratio when the terminal is resized (tmux zoom, monitor switch).
    vim.api.nvim_create_autocmd("VimResized", {
      callback = function()
        if enabled() then
          vim.cmd("NoNeckPainResize " .. width())
        end
      end,
    })
  end,
}
