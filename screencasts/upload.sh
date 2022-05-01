#!/usr/bin/env bash
SCREENCAST_DIR="screencasts"
GIF_THEME=${GIF_THEME:-asciinema}
GIF_SCALE=${GIF_SCALE:-1}
SCREENCAST_README="${SCREENCAST_DIR}/README.md"
TOP_LEVEL_README="README.md"

screencast_names() {
  cd "$SCREENCAST_DIR" || exit
  for f in *.cast; do
    echo "${f%.cast}"
  done
}

upload() { local name="$1"
  asciinema upload "${SCREENCAST_DIR}/${name}.cast"
}

asciinema_id() {
  grep 'asciinema.org' | cut -d'/' -f5
}

asciicast2gif() {
  docker run --rm -v "$PWD:/data" asciinema/asciicast2gif "$@"
}

screencast_md() { local name="$1" asciinema_id="$2"
  # create a gif but send output to stderr
  >&2 asciicast2gif -t "${GIF_THEME}" -S "${GIF_SCALE}" "${SCREENCAST_DIR}/${name}.cast" "${SCREENCAST_DIR}/${name}.gif"

  cat <<-EOF 
## ${name}
[![${name}.cast](${name}.gif)](https://asciinema.org/a/${asciinema_id})

EOF
}

screencasts_md() {
  cat <<-EOF
# Screencasts
EOF

  for name in $(screencast_names); do
    screencast_md "$name" "$(upload "$name" | asciinema_id)"
  done
}

update_screencasts_in() { local file="$1"
  # shellcheck disable=SC2013
  for cast_tag in $(grep '\[!\[.*.cast\](.*.gif)\](https://asciinema.org/a/.*)'); do
    # shellcheck disable=SC1073,SC2001
    read -r cast_gif cast_url < <(echo "$cast_tag" | sed 's/.*(\(.*.gif\).*(\(.*\))/\1 \2/')
    cast_file=${cast_gif/gif/cast}

    new="[![${cast_file}](${SCREENCAST_DIR}/${cast_gif})](${cast_url})"
    sed -i.bak "s|\[!\[${cast_file}\](screencasts/${cast_gif})\](https://asciinema.org/a/.*)|$new|g" "$file"
    rm "${file}.bak"
  done
}

screencasts_md |
  tee "$SCREENCAST_README" |
  update_screencasts_in "$TOP_LEVEL_README"
