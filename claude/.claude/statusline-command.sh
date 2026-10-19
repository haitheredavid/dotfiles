#!/usr/bin/env bash
# Claude Code status line — model, session timer, context bar, rate limits, git diff count
# --multi, or "multi" in ~/.claude/statusline-mode, adds a second line with prompt cache state and stats

multi=false
[ "$1" = "--multi" ] && multi=true
[ "$(cat ~/.claude/statusline-mode 2>/dev/null)" = "multi" ] && multi=true

input=$(cat)
j() { echo "$input" | jq -r "$1 // empty"; }

cwd=$(j '.workspace.current_dir // .cwd')
model=$(j '.model.display_name')
duration_ms=$(j '.cost.total_duration_ms')
used_pct=$(j '.context_window.used_percentage')
cache_warm=$(echo "$input" | jq -r '.prompt_cache.warm | select(. != null)')
cache_hit=$(j '.prompt_cache.hit_ratio')
cache_expires=$(j '.prompt_cache.expires_at')
cache_recache=$(j '.prompt_cache.recache_tokens_if_cold')
cache_miss=$(j '.prompt_cache.last_miss_cause.causes | select(length > 0) | join(",")')
cache_requests=$(j '.prompt_cache.requests')
cache_misses=$(j '.prompt_cache.misses')
cache_writes=$(j '.prompt_cache.cache_write_tokens')
five=$(j '.rate_limits.five_hour.used_percentage')
week=$(j '.rate_limits.seven_day.used_percentage')

FILL='\033[37m'; GREY='\033[90m'; RESET='\033[0m'

human() {
    if [ "$1" -ge 1000000 ]; then
        awk -v n="$1" 'BEGIN { v = n / 1000000; printf (v == int(v) ? "%dM" : "%.1fM"), v }'
    elif [ "$1" -ge 1000 ]; then printf '%dk' $(( ($1 + 500) / 1000 ))
    else printf '%d' "$1"; fi
}

elapsed() {
    local s=$1 h m
    h=$(( s / 3600 )); m=$(( s % 3600 / 60 ))
    if [ "$h" -gt 0 ]; then printf '%dh%02dm' "$h" "$m"
    elif [ "$m" -gt 0 ]; then printf '%dm' "$m"
    else printf '%ds' "$s"; fi
}

bar() {
    local pct=$1 width=10 filled i out=""
    filled=$(( (pct * width + 50) / 100 ))
    [ "$filled" -gt "$width" ] && filled=$width
    out+="$FILL"
    for ((i = 0; i < filled; i++)); do out+="█"; done
    out+="$GREY"
    for ((i = filled; i < width; i++)); do out+="░"; done
    printf '%s' "$out"
}

parts=()

model="${model%% (*}"
[ -n "$model" ] && parts+=("$model")

[ -n "$duration_ms" ] && parts+=("$(elapsed $(( ${duration_ms%.*} / 1000 )))")

if [ -n "$used_pct" ]; then
    pct=$(printf '%.0f' "$used_pct")
    parts+=("$(bar "$pct") ${pct}%")
fi

limits=""
[ -n "$five" ] && limits="5h:$(printf '%.0f' "$five")%"
[ -n "$week" ] && limits="${limits:+$limits }7d:$(printf '%.0f' "$week")%"
[ -n "$limits" ] && parts+=("$limits")

if [ -n "$cwd" ] && stat=$(git -C "$cwd" --no-optional-locks diff --shortstat HEAD 2>/dev/null); then
    added=$(echo "$stat" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+')
    removed=$(echo "$stat" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+')
    parts+=("+${added:-0} -${removed:-0}")
fi

join() {
    local out="" p
    for p in "$@"; do out+="${out:+ | }${p}"; done
    printf '%s' "$out"
}

out=$(join "${parts[@]}")

if $multi; then
    stats=()
    if [ -n "$cache_warm" ]; then
        cache="cache"
        [ -n "$cache_hit" ] && cache+=" $(awk -v r="$cache_hit" 'BEGIN { printf "%.0f", r * 100 }')%"
        if [ "$cache_warm" = "true" ] && [ -n "$cache_expires" ]; then
            left=$(( cache_expires - $(date +%s) ))
            [ "$left" -lt 0 ] && left=0
            cache+=" warm $(elapsed "$left")"
        else
            cache+=" cold"
            [ -n "$cache_recache" ] && cache+=" +$(human "$cache_recache")"
        fi
        stats+=("$cache")
        [ -n "$cache_misses" ] && [ -n "$cache_requests" ] && stats+=("${cache_misses}/${cache_requests} misses")
        [ -n "$cache_miss" ] && stats+=("miss:${cache_miss}")
        [ -n "$cache_writes" ] && stats+=("writes $(human "$cache_writes")")
    fi
    [ ${#stats[@]} -gt 0 ] && out+=$'\n'"$(join "${stats[@]}")"
fi

printf '%b%b%b' "$GREY" "${out//$'\n'/$RESET$'\n'$GREY}" "$RESET"
