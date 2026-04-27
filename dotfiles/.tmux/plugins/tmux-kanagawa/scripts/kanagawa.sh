#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $current_dir/utils.sh
source $current_dir/colors.sh
source $current_dir/theme.sh

main() {
  tmux bind-key -r T run-shell "#{@kanagawa-root}/menu_items/main.sh"

  # set theme
  theme=$(get_tmux_option "@kanagawa-theme" "")
  ignore_window_colors=$(get_tmux_option "@kanagawa-ignore-window-colors" false)

  set_theme $theme
  override_theme_colors

  # set configuration option variables
  show_kubernetes_context_label=$(get_tmux_option "@kanagawa-kubernetes-context-label" "")
  eks_hide_arn=$(get_tmux_option "@kanagawa-kubernetes-eks-hide-arn" false)
  eks_extract_account=$(get_tmux_option "@kanagawa-kubernetes-eks-extract-account" false)
  hide_kubernetes_user=$(get_tmux_option "@kanagawa-kubernetes-hide-user" false)
  terraform_label=$(get_tmux_option "@kanagawa-terraform-label" "")
  show_fahrenheit=$(get_tmux_option "@kanagawa-show-fahrenheit" false)
  show_location=$(get_tmux_option "@kanagawa-show-location" true)
  fixed_location=$(get_tmux_option "@kanagawa-fixed-location")
  show_powerline=$(get_tmux_option "@kanagawa-show-powerline" false)
  show_flags=$(get_tmux_option "@kanagawa-show-flags" false)
  status_bg=$(get_tmux_option "@kanagawa-status-bg" bg_bar)

  # left icon area
  left_icon=$(get_tmux_option "@kanagawa-left-icon" session)
  left_icon_bg=$(get_tmux_option "@kanagawa-left-icon-bg" accent)
  left_icon_fg=$(get_tmux_option "@kanagawa-left-icon-fg" bg_pane)
  left_icon_prefix_bg=$(get_tmux_option "@kanagawa-left-icon-prefix-on-bg" alert)
  left_icon_prefix_fg=$(get_tmux_option "@kanagawa-left-icon-prefix-on-fg" bg_pane)
  left_icon_padding_left=$(get_tmux_option "@kanagawa-left-icon-padding-left" 1)
  left_icon_padding_right=$(get_tmux_option "@kanagawa-left-icon-padding-right" 1)
  left_icon_margin_right=$(get_tmux_option "@kanagawa-left-icon-margin-right" 1)
  show_left_icon_padding=$(get_tmux_option "@kanagawa-left-icon-padding" 1)
  show_military=$(get_tmux_option "@kanagawa-military-time" false)
  timezone=$(get_tmux_option "@kanagawa-set-timezone" "")
  show_timezone=$(get_tmux_option "@kanagawa-show-timezone" true)
  show_left_sep=$(get_tmux_option "@kanagawa-show-left-sep" )
  show_right_sep=$(get_tmux_option "@kanagawa-show-right-sep" )
  show_border_contrast=$(get_tmux_option "@kanagawa-border-contrast" false)
  show_day_month=$(get_tmux_option "@kanagawa-day-month" false)
  show_refresh=$(get_tmux_option "@kanagawa-refresh-rate" 5)
  show_synchronize_panes_label=$(get_tmux_option "@kanagawa-synchronize-panes-label" "Sync")
  time_format=$(get_tmux_option "@kanagawa-time-format" "")
  show_ssh_session_port=$(get_tmux_option "@kanagawa-show-ssh-session-port" false)
  IFS=' ' read -r -a plugins <<<$(get_tmux_option "@kanagawa-plugins" "battery network weather")
  show_empty_plugins=$(get_tmux_option "@kanagawa-show-empty-plugins" true)

  # Handle left icon configuration
  case $left_icon in
  smiley)
    left_icon_content="☺"
    ;;
  session)
    left_icon_content="#S"
    ;;
  window)
    left_icon_content="#W"
    ;;
  hostname)
    left_icon_content="#H"
    ;;
  username)
    left_icon=$(whoami)
    ;;
  shortname)
    left_icon_content="#h"
    ;;
  *)
    left_icon_content=$left_icon
    ;;
  esac

  icon_pd_l=""
  if [ "$left_icon_padding_left" -gt "0" ]; then
    icon_pd_l="$(printf '%*s' $left_icon_padding_left)"
  fi
  icon_pd_r=""
  if [ "$left_icon_padding_right" -gt "0" ]; then
    icon_pd_r="$(printf '%*s' $left_icon_padding_right)"
  fi

  # Handle powerline option
  if $show_powerline; then
    left_sep="$show_left_sep"
    right_sep="$show_right_sep"
  else # if disable powerline mark, equal to '', unify the logic of string.
    left_sep=''
    right_sep=''
    window_left_sep=''
    window_right_sep=''
  fi

  # Left icon, with prefix status
  tmux set-option -g status-left "#{?client_prefix,#[fg=${!left_icon_prefix_fg}],#[fg=${!left_icon_fg}]}#{?client_prefix,#[bg=${!left_icon_prefix_bg}],#[bg=${!left_icon_bg}]}${icon_pd_l}${left_icon_content}${icon_pd_r}#{?client_prefix,#[fg=${!left_icon_prefix_bg}],#[fg=${!left_icon_bg}]}#[bg=${!status_bg}]${left_sep}${icon_mg_r}"
  powerbg=${!status_bg}

  # Set timezone unless hidden by configuration
  if [[ -z "$timezone" ]]; then
    case $show_timezone in
    false)
      timezone=""
      ;;
    true)
      timezone="#(date +%Z)"
      ;;
    esac
  fi

  case $show_flags in
  false)
    flags=""
    current_flags=""
    ;;
  true)
    flags="#{?window_flags,#[fg=${selection}]#{window_flags},}"
    current_flags="#{?window_flags,#[fg=${highlight}]#{window_flags},}"
    ;;
  esac

  # sets refresh interval to every 5 seconds
  tmux set-option -g status-interval $show_refresh

  # set the prefix + t time format
  if $show_military; then
    tmux set-option -g clock-mode-style 24
  else
    tmux set-option -g clock-mode-style 12
  fi

  # set length
  tmux set-option -g status-left-length 100
  tmux set-option -g status-right-length 100

  # pane border styling
  if $show_border_contrast; then
    tmux set-option -g pane-active-border-style "fg=${highlight}"
  else
    tmux set-option -g pane-active-border-style "fg=${selection}"
  fi
  tmux set-option -g pane-border-style "fg=${bg_bar}"

  # message styling
  tmux set-option -g message-style "bg=${bg_bar},fg=${text}"

  # status bar
  tmux set-option -g status-style "bg=${!status_bg},fg=${text}"

  # Handle left icon margin
  icon_mg_r=""
  if [ "$left_icon_margin_right" -gt "0" ]; then
    icon_mg_r="$(printf '%*s' $left_icon_margin_right)"
  fi

  # Status right
  tmux set-option -g status-right ""

  for plugin in "${plugins[@]}"; do

    if case $plugin in custom:*) true ;; *) false ;; esac then
      script=${plugin#"custom:"}
      if [[ -x "${current_dir}/${script}" ]]; then
        IFS=' ' read -r -a colors <<<$(get_tmux_option "@kanagawa-custom-plugin-colors" "info bg_pane")
        script="#($current_dir/${script})"
      else
        colors[0]="error"
        colors[1]="bg_pane"
        script="${script} not found!"
      fi

    elif [ $plugin = "cwd" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@kanagawa-cwd-colors" "bg_pane text")
      tmux set-option -g status-right-length 250
      script="#($current_dir/cwd.sh)"

    elif [ $plugin = "fossil" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@kanagawa-fossil-colors" "accent bg_pane")
      tmux set-option -g status-right-length 250
      script="#($current_dir/fossil.sh)"

    elif [ $plugin = "git" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@kanagawa-git-colors" "accent bg_pane")
      tmux set-option -g status-right-length 250
      script="#($current_dir/git.sh)"

    elif [ $plugin = "hg" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@kanagawa-hg-colors" "accent bg_pane")
      tmux set-option -g status-right-length 250
      script="#($current_dir/hg.sh)"

    elif [ $plugin = "battery" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@kanagawa-battery-colors" "muted bg_pane")
      script="#($current_dir/battery.sh)"

    elif [ $plugin = "gpu-usage" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@kanagawa-gpu-usage-colors" "muted bg_pane")
      script="#($current_dir/gpu_usage.sh)"

    elif [ $plugin = "gpu-ram-usage" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@kanagawa-gpu-ram-usage-colors" "info bg_pane")
      script="#($current_dir/gpu_ram_info.sh)"

    elif [ $plugin = "gpu-power-draw" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@kanagawa-gpu-power-draw-colors" "accent bg_pane")
      script="#($current_dir/gpu_power.sh)"

    elif [ $plugin = "cpu-usage" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@kanagawa-cpu-usage-colors" "notice bg_pane")
      script="#($current_dir/cpu_info.sh)"

    elif [ $plugin = "ram-usage" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@kanagawa-ram-usage-colors" "info bg_pane")
      script="#($current_dir/ram_info.sh)"

    elif [ $plugin = "tmux-ram-usage" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@kanagawa-tmux-ram-usage-colors" "info bg_pane")
      script="#($current_dir/tmux_ram_info.sh)"

    elif [ $plugin = "network" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@kanagawa-network-colors" "info bg_pane")
      script="#($current_dir/network.sh)"

    elif [ $plugin = "network-bandwidth" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@kanagawa-network-bandwidth-colors" "info bg_pane")
      tmux set-option -g status-right-length 250
      script="#($current_dir/network_bandwidth.sh)"

    elif [ $plugin = "network-ping" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@kanagawa-network-ping-colors" "info bg_pane")
      script="#($current_dir/network_ping.sh)"

    elif [ $plugin = "network-vpn" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@kanagawa-network-vpn-colors" "info bg_pane")
      script="#($current_dir/network_vpn.sh)"

    elif [ $plugin = "attached-clients" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@kanagawa-attached-clients-colors" "info bg_pane")
      script="#($current_dir/attached_clients.sh)"

    elif [ $plugin = "mpc" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@kanagawa-mpc-colors" "accent bg_pane")
      script="#($current_dir/mpc.sh)"

    elif [ $plugin = "spotify-tui" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@kanagawa-spotify-tui-colors" "accent bg_pane")
      script="#($current_dir/spotify-tui.sh)"

    elif [ $plugin = "playerctl" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@kanagawa-playerctl-colors" "accent bg_pane")
      script="#($current_dir/playerctl.sh)"

    elif [ $plugin = "kubernetes-context" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@kanagawa-kubernetes-context-colors" "info bg_pane")
      script="#($current_dir/kubernetes_context.sh $eks_hide_arn $eks_extract_account $hide_kubernetes_user $show_kubernetes_context_label)"

    elif [ $plugin = "terraform" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@kanagawa-terraform-colors" "highlight bg_pane")
      script="#($current_dir/terraform.sh $terraform_label)"

    elif [ $plugin = "continuum" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@kanagawa-continuum-colors" "info bg_pane")
      script="#($current_dir/continuum.sh)"

    elif [ $plugin = "weather" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@kanagawa-weather-colors" "notice bg_pane")
      script="#($current_dir/weather_wrapper.sh $show_fahrenheit $show_location '$fixed_location')"

    elif [ $plugin = "time" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@kanagawa-time-colors" "selection text")
      if [ -n "$time_format" ]; then
        script=${time_format}
      else
        if $show_day_month && $show_military; then # military time and dd/mm
          script="%a %d/%m %R ${timezone} "
        elif $show_military; then # only military time
          script="%a %m/%d %R ${timezone} "
        elif $show_day_month; then # only dd/mm
          script="%a %d/%m %I:%M %p ${timezone} "
        else
          script="%a %m/%d %I:%M %p ${timezone} "
        fi
      fi
    elif [ $plugin = "synchronize-panes" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@kanagawa-synchronize-panes-colors" "info bg_pane")
      script="#($current_dir/synchronize_panes.sh $show_synchronize_panes_label)"

    elif [ $plugin = "ssh-session" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@kanagawa-ssh-session-colors" "accent bg_pane")
      script="#($current_dir/ssh_session.sh $show_ssh_session_port)"

    else
      continue
    fi

    if $show_powerline; then
      if $show_empty_plugins; then
        tmux set-option -ga status-right "#[fg=${!colors[0]},bg=${powerbg},nobold,nounderscore,noitalics]${right_sep}#[fg=${!colors[1]},bg=${!colors[0]}] $script "
      else
        tmux set-option -ga status-right "#{?#{==:$script,},,#[fg=${!colors[0]},nobold,nounderscore,noitalics]${right_sep}#[fg=${!colors[1]},bg=${!colors[0]}] $script }"
      fi
      powerbg=${!colors[0]}
    else
      if $show_empty_plugins; then
        tmux set-option -ga status-right "#[fg=${!colors[1]},bg=${!colors[0]}] $script "
      else
        tmux set-option -ga status-right "#{?#{==:$script,},,#[fg=${!colors[1]},bg=${!colors[0]}] $script }"
      fi
    fi
  done

  # Window option
  if $show_powerline; then
    tmux set-window-option -g window-status-current-format "#[fg=${bg_bar},bg=${selection}]${left_sep}#[fg=${text},bg=${selection}] #I #W${current_flags} #[fg=${selection},bg=${bg_bar}]${left_sep}"
  else
    tmux set-window-option -g window-status-current-format "#[fg=${text},bg=${selection}] #I #W${current_flags} "
  fi

  if ! $ignore_window_colors; then
    tmux set-window-option -g window-style "fg=${text},bg=${bg_pane}"
  fi

  tmux set-window-option -g window-status-format "#[fg=${text}]#[bg=${bg_bar}] #I #W${flags}"
  tmux set-window-option -g window-status-activity-style "bold"
  tmux set-window-option -g window-status-bell-style "bold"
}

# run main function
main
