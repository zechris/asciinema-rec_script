# asciinema-rec_script
Record output from shell scripts as well as their comments and code.

This is done by building an augmented version of the original script that surfaces all the code & comments.
Then passing that to asciinema's [rec --command](https://github.com/asciinema/asciinema#rec-filename) command.


## Motivation

The [asciinema](https://asciinema.org) tool is an awesome terminal session recorder.

And it has a [rec [filename]](https://github.com/asciinema/asciinema#rec-filename) command with a `-c --command=<command>` option.

This specifies a `command` to record (other than the default of `$SHELL`)

So given an (executable) script `demo-date_maths`:
```bash
#!/usr/bin/env bash
## Date maths

# The `date` command can be used to retrieve the:
#  * *day of the week* using the `%l` option
day_of_the_week=$(date +%l)

#  * *hour of the day* using the `%u` option
hour=$(date +%u)


# Now, can you guess what we're going to do with those two numbers?
# 🤔...
sleep 3

# We're going to add them together!
echo $((day_of_the_week + hour))
```

We can use asciinema's `rec` to make a recording:
```
asciinema rec --command screencasts/demo-date_maths
```


However that recording is going to lose a bunch of context from the script and end up looking something like this:
<img width="808" alt="Screen Shot 2021-10-17 at 19 49 14" src="https://user-images.githubusercontent.com/49626717/137619503-05ec8492-f2df-4bc3-a410-ad3300223b8f.png">

If, however we instead used this command:
```
asciinema-rec_script screencasts/demo-date_maths
```

Without *any* effort we can end up with a recording like this:
[![asciicast](https://asciinema.org/a/pSQTIOh50qKqvU5BFE7tAB5gx.svg)](https://asciinema.org/a/pSQTIOh50qKqvU5BFE7tAB5gx)


## Getting Started
### Installation:
Place `asciinema-rec_script` somewhere in your $PATH.


#### Requirements:
 * [asciinema](https://asciinema.org) ([installation](https://github.com/asciinema/asciinema#installation))
 * bash
 * (optional) [bat](https://github.com/sharkdp/bat) ([installation](https://github.com/sharkdp/bat#installation)) # A cat clone to provide syntax highlighting


### Example Usages:
 * `asciinema-rec_script ./screencasts/demo-date_maths`     # No additional arguments will pass `asciinema rec` a filename of `./screencasts/demo-date_maths.cast` to place the recording in
 * `./screencasts/demo-date_maths.asc`                      # Will take advantage of the shebang line `#!/usr/bin/env asciinema-rec_script` in the `.asc` script
 * `./screencasts/demo-date_maths.asc --`                   # Allows `asciinema rec` to receive no additional arguments (eg. `--` for no arguments, which will allow it to maintain its default behaviour of uploading to https://asciinema.org)
 * `SLEEP=0 ./screencasts/demo-bash_functions.asc`          # Will pass any necessary env vars to the script
 * `source ./screencasts/demo-date_maths.asc`               # Will source the .asc script in your $SHELL (which should be ~roughly~ compatible with bash)

(Nb. the `.asc` extension ("ASCiinema") is not strictly necessary, but gives some uniformity.)


### How it works
`asciinema-rec_script` (written in bash) reads from the file passed to it one line at a time and will detect:
 * ❯ _lines of code_ (syntax highlighting them as bash code)
 * 💭 _comments_ (syntax highlighting them as markdown)
 * _blank lines_ (preserving whitespace)
 * 💬 and some other _special lines_

It uses meta-programming to build an augmented version of itself from each of these lines storing them in a temporary `augmented_script` file.

And finally it passes that file (and any other arguments specified on the command line) to `asciinema run --command <augmented_script>` for it to make a recording.



## Also included
### asciinema-gh
#### Requirements:
 * [asciinema](https://asciinema.org)
 * [gh](https://github.com/cli/cli)
 * [jq](https://stedolan.github.io/jq)


#### Example Usages:
 * `asciinema-gh zechris/asciinema-rec_script`
   * search for .cast files in https://github.com/zechris/asciinema-rec_script/tree/master/screencasts
 * `REF=first_pr asciinema-gh zechris/asciinema-rec_script` 
   * search for .cast files in https://github.com/zechris/asciinema-rec_script/tree/first_pr/screencasts
 * `asciinema-gh spectreconsole/spectre.console docs/input/assets/casts`
   * search for .cast files in https://github.com/spectreconsole/spectre.console/tree/master/docs/input/assets/casts
 * `echo 26 | screencast_dir=docs/input/assets/casts asciinema-gh spectreconsole/spectre.console`
   * ... and select number `26`

[![asciicast](https://asciinema.org/a/uiqC0yZrCP9UPGqWaX5Wnf7wF.svg)](https://asciinema.org/a/uiqC0yZrCP9UPGqWaX5Wnf7wF)
