set_theme() {
  case $1 in
  dragon)
    text=$old_white
    bg_bar=$dragon_black_4
    bg_pane=$dragon_black_2
    highlight=$dragon_orange
    selection=$dragon_black_5
    info=$dragon_teal
    accent=$dragon_ash
    notice=$dragon_yellow
    error=$dragon_red
    muted=$dragon_orange
    alert=$dragon_yellow
    ;;
  lotus)
    text=$lotus_white_3
    bg_bar=$lotus_yellow_2
    bg_pane=$lotus_white_3
    highlight=$lotus_red_4
    selection=$lotus_red_4
    info=$lotus_cyan
    accent=$lotus_red_2
    notice=$lotus_aqua_2
    error=$lotus_red_4
    muted=$lotus_pink
    alert=$lotus_teal_3
    ;;
  *)
    text=$fuji_white
    bg_bar=$sumi_ink_4
    bg_pane=$sumi_ink_3
    highlight=$sumi_ink_5
    selection=$sumi_ink_6
    info=$wave_aqua
    accent=$spring_violet_1
    notice=$autumn_orange
    error=$wave_red
    muted=$sakura_pink
    alert=$ronin_yellow
    ;;
  esac

  # Legacy aliases (deprecated - for backward compatibility)
  white=$text
  gray=$bg_bar
  dark_gray=$bg_pane
  light_purple=$highlight
  dark_purple=$selection
  cyan=$info
  green=$accent
  orange=$notice
  red=$error
  pink=$muted
  yellow=$alert
}

override_theme_colors() {
  local semantic_names="text bg_bar bg_pane highlight selection info accent notice error muted alert"

  for name in $semantic_names; do
    local option_name="@kanagawa-color-${name//_/-}"
    local custom_value=$(get_tmux_option "$option_name" "")

    if [ -n "$custom_value" ]; then
      if [[ "$custom_value" == \#* ]]; then
        printf -v "$name" "%s" "$custom_value"
      else
        printf -v "$name" "%s" "${!custom_value}"
      fi
    fi
  done

  # Re-apply legacy aliases after overrides
  white=$text
  gray=$bg_bar
  dark_gray=$bg_pane
  light_purple=$highlight
  dark_purple=$selection
  cyan=$info
  green=$accent
  orange=$notice
  red=$error
  pink=$muted
  yellow=$alert
}
