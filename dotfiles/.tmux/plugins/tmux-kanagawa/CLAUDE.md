# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

tmux-kanagawa is a tmux theme plugin based on the [Kanagawa](https://github.com/rebelot/kanagawa.nvim) color palette, forked from dracula/tmux. It provides a customizable status bar with various plugins for displaying system information.

## Architecture

### Entry Point
- `kanagawa.tmux` - Main entry point, sources `scripts/kanagawa.sh`

### Core Scripts (scripts/)
- `kanagawa.sh` - Main theme logic, plugin loading, and status bar configuration
- `colors.sh` - Kanagawa color palette definitions (all color variables)
- `theme.sh` - Theme variants (wave/dragon/lotus) mapping colors to semantic names
- `utils.sh` - Shared utilities (`get_tmux_option`, `normalize_percent_len`, `installed`)
- `state.sh` - State management for runtime option overrides

### Plugin Scripts (scripts/)
Each plugin is a standalone bash script that outputs text for the status bar:
- `battery.sh`, `cpu_info.sh`, `ram_info.sh`, `gpu_usage.sh` - System metrics
- `git.sh`, `hg.sh`, `fossil.sh` - Version control status
- `network.sh`, `network_bandwidth.sh`, `network_ping.sh`, `network_vpn.sh` - Network info
- `weather.sh`, `weather_wrapper.sh` - Weather display
- `kubernetes_context.sh`, `terraform.sh` - DevOps tools
- `spotify-tui.sh`, `playerctl.sh`, `mpc.sh` - Music players
- `ssh_session.sh`, `cwd.sh`, `attached_clients.sh`, `synchronize_panes.sh`, `continuum.sh`

### Menu System (menu_items/)
Interactive tmux menus accessible via `prefix + T`:
- `main.sh` - Main menu entry point
- `colors.sh`, `plugins.sh`, `options.sh` - Submenu handlers

## Color System

Colors are defined in `scripts/colors.sh` using Kanagawa naming conventions (e.g., `fuji_white`, `sumi_ink_4`, `spring_green`).

`scripts/theme.sh` maps these to role-based semantic names based on the selected theme variant:
- **wave** (default) - Dark theme
- **dragon** - Darker variant
- **lotus** - Light theme

### Semantic Color Names
| Name | Role |
|------|------|
| `text` | Primary text/foreground |
| `bg_bar` | Status bar background |
| `bg_pane` | Window/pane background |
| `highlight` | Active element highlight |
| `selection` | Selected/focused element |
| `info` | Informational status (network, system) |
| `accent` | Primary accent (VCS, success states) |
| `notice` | Performance/attention (CPU, weather) |
| `error` | Error states |
| `muted` | Secondary status (battery, GPU) |
| `alert` | Prefix/alert active state |

Legacy color names (`white`, `gray`, `dark_gray`, `light_purple`, `dark_purple`, `cyan`, `green`, `orange`, `red`, `pink`, `yellow`) are aliased for backward compatibility.

## Configuration Pattern

All options use the `@kanagawa-` prefix and are read via `get_tmux_option`:
```bash
show_powerline=$(get_tmux_option "@kanagawa-show-powerline" false)
```

Plugin colors are customizable via:
```bash
set -g @kanagawa-[plugin-name]-colors "[background] [foreground]"
```

## Adding a New Plugin

1. Create `scripts/your_plugin.sh` (must be executable, output text to stdout)
2. Add handling in `scripts/kanagawa.sh` in the plugin loop:
   ```bash
   elif [ $plugin = "your-plugin" ]; then
     IFS=' ' read -r -a colors <<<$(get_tmux_option "@kanagawa-your-plugin-colors" "info bg_pane")
     script="#($current_dir/your_plugin.sh)"
   ```

## Testing Changes

Reload tmux configuration after changes:
```bash
tmux source-file ~/.tmux.conf
```

Or restart the tmux server for a clean state.
