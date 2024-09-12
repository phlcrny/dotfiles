--[[
Inspiration/reference:
    https://gilbertsanchez.com/posts/my-terminal-wezterm/
    https://gist.github.com/gsuuon/5511f0aa10c10c6cbd762e0b3e596b71
    https://github.com/nicksp/dotfiles
    https://github.com/KevinSilvester/wezterm-config
    Probably some others too
]] --
local wezterm = require 'wezterm'
local mux = wezterm.mux
local act = wezterm.action
local config = {}
local launch_menu = {}
local hasextras, extras = pcall(require, ".wezterm_extras")
--[[

core configuration

]] --

config.audible_bell = "Disabled"
config.launch_menu = launch_menu

--[[

formatting and theming!

]] --

config.color_scheme = "Dracula (Official)"
config.command_palette_rows = 10
config.command_palette_bg_color = "#282a36"
config.command_palette_fg_color = "#bd93f9"
config.default_cursor_style = 'BlinkingBar'
config.enable_scroll_bar = true
config.font = wezterm.font_with_fallback({{
    family = "CaskaydiaCove Nerd Font Mono"
}, {
    family = "CaskaydiaCove NF Mono"
}})
config.font_size = 14
config.initial_cols = 100
config.initial_rows = 30
config.show_tab_index_in_tab_bar = true
config.tab_bar_at_bottom = false
config.tab_max_width = 120
config.use_fancy_tab_bar = false
config.window_background_opacity = 0.80
config.window_decorations = "RESIZE"
config.window_padding = {
    left = 10,
    right = 10,
    top = 5,
    bottom = 5
}

-- right status starts
wezterm.on('update-right-status', function(window, pane)
    local cells = {}
    table.insert(cells, window:active_workspace())
    local username = os.getenv('USERNAME') or os.getenv('USER') or os.getenv('LOGNAME')
    table.insert(cells, username)
    local cwd_uri = pane:get_current_working_dir()
    if cwd_uri then
        local cwd = ''
        local hostname = ''

        local dot = hostname:find '[.]'
        if dot then
            hostname = hostname:sub(1, dot - 1)
        end
        if hostname == '' then
            hostname = wezterm.hostname()
        end

        table.insert(cells, hostname)
    end

    for _, b in ipairs(wezterm.battery_info()) do
        table.insert(cells, string.format('%.0f%%', b.state_of_charge * 100))
    end

    local date = wezterm.strftime '%A %B %-d %H:%M'
    table.insert(cells, date)
    local LEFT_CIRCLE = wezterm.nerdfonts.ple_left_half_circle_thin
    local SOLID_LEFT_CIRCLE = wezterm.nerdfonts.ple_left_half_circle_thick
    local SOLID_RIGHT = wezterm.nerdfonts.ple_right_half_circle_thick
    local SOLID_LEFT = wezterm.nerdfonts.ple_left_half_circle_thick

    local lavender = wezterm.color.parse("#bd93f9")
    local colors = {lavender, lavender:lighten(0.2), lavender:lighten(0.1), lavender, lavender:darken(0.1),
                    lavender:darken(0.2)}
    local grey = '#282a36'
    local elements = {}
    local num_cells = 0

    function push(text, is_last)
        local cell_no = num_cells + 1
        -- Left element edge
        table.insert(elements, {
            Foreground = {
                Color = colors[cell_no]
            }
        })
        table.insert(elements, {
            Background = {
                Color = grey
            }
        })
        table.insert(elements, {
            Foreground = {
                Color = colors[cell_no + 1]
            }
        })
        table.insert(elements, {
            Text = " " .. SOLID_LEFT .. ""
        })

        -- Centre/text element
        table.insert(elements, {
            Background = {
                Color = colors[cell_no + 1]
            }
        })
        table.insert(elements, {
            Foreground = {
                Color = grey
            }
        })
        table.insert(elements, {
            Text = text
        })

        -- Right element edge
        table.insert(elements, {
            Background = {
                Color = grey
            }
        })
        table.insert(elements, {
            Foreground = {
                Color = colors[cell_no + 1]
            }
        })
        table.insert(elements, {
            Text = "" .. SOLID_RIGHT .. " "
        })
        table.insert(elements, {
            Foreground = {
                Color = colors[cell_no + 1]
            }
        })
    end

    while #cells > 0 do
        local cell = table.remove(cells, 1)
        push(cell, #cells == 0)
    end

    window:set_right_status(wezterm.format(elements))
end)
-- right status ends

function tab_title(tab_info)
    local title = tab_info.tab_title
    if title and #title > 0 then
        return title
    end
    return tab_info.active_pane.title
end

--- format-tab-title starts
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)

    local SOLID_RIGHT = wezterm.nerdfonts.ple_right_half_circle_thick
    local SOLID_LEFT = wezterm.nerdfonts.ple_left_half_circle_thick
    local lavender = wezterm.color.parse('#bd93f9')
    local grey = wezterm.color.parse('#282a36')
    local icon = wezterm.nerdfonts.cod_question

    if tab.is_active then
        background = lavender
        foreground = grey
        icon = wezterm.nerdfonts.cod_debug_start
    elseif hover then
        background = grey
        foreground = lavender
        icon = wezterm.nerdfonts.cod_debug_continue
    else
        background = lavender:lighten(0.4)
        foreground = grey
        icon = wezterm.nerdfonts.cod_debug_pause
    end

    local edge_background = grey
    local edge_foreground = background
    local title = tab_title(tab)

    title = wezterm.truncate_right(icon .. ' ' .. title, max_width + 50)

    return {{
        -- Left element edge
        Background = {
            Color = edge_background
        }
    }, {
        Foreground = {
            Color = edge_foreground
        }
    }, {
        Text = " " .. SOLID_LEFT
        -- Centre/text element
    }, {
        Background = {
            Color = background
        }
    }, {
        Foreground = {
            Color = foreground
        }
    }, {
        Text = title
        -- Right element edge
    }, {
        Background = {
            Color = edge_background
        }
    }, {
        Foreground = {
            Color = edge_foreground
        }
    }, {
        Text = SOLID_RIGHT .. " "
    }}
end)
--- format-tab-title ends

--[[

OS-specifics

]] --

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
    local success, stdout, stderr = wezterm.run_child_process {'cmd.exe', 'ver'}
    local major, minor, build, rev = stdout:match("Version ([0-9]+)%.([0-9]+)%.([0-9]+)%.([0-9]+)")
    config.default_prog = {'pwsh.exe', '-NoLogo'}
    table.insert(launch_menu, {
        label = 'Powershell',
        args = {'powershell.exe', '-NoLogo'}
    })
    table.insert(launch_menu, {
        label = 'pwsh',
        args = {'pwsh.exe', '-NoLogo'}
    })
else
    config.default_prog = {'/bin/zsh'}
    table.insert(launch_menu, {
        label = 'zsh',
        args = {'/bin/zsh'}
    })
end

--[[

actions/keys

]] --

mouse_bindings = {{
    event = {
        Up = {
            streak = 1,
            button = "Left"
        }
    },
    mods = "NONE",
    action = act.CompleteSelection("ClipboardAndPrimarySelection")
}, {
    event = {
        Up = {
            streak = 1,
            button = "Left"
        }
    },
    mods = "CTRL",
    action = act.OpenLinkAtMouseCursor
}, {
    event = {
        Down = {
            streak = 3,
            button = "Left"
        }
    },
    action = wezterm.action.SelectTextAtMouseCursor("SemanticZone"),
    mods = "NONE"
}}
config.mouse_bindings = mouse_bindings

--[[

Start-up

]] --

wezterm.on('gui-startup', function(cmd)
    local args = {}
    if cmd then
        args = cmd.args
    end

    local starting_dir = wezterm.home_dir
    local tab, main_pane, window = mux.spawn_window {
        workspace = 'main',
        cwd = starting_dir,
        args = config.default_prog
    }
    mux.set_active_workspace 'main'
end)

--[[

override file

]] --

if hasextras then
    extras.apply_to_config(config)
end

return config
