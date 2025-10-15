SPACESHIP_PROMPT_ORDER=(
  time           # Time stamps section
  # user           # Username section
  dir            # Current directory section
  # host           # Hostname section
  git            # Git section (git_branch + git_status + [git_commit](default off))
  # hg             # Mercurial section (hg_branch  + hg_status)
  # package        # Package version
  node           # Node.js section
  # bun            # Bun section
  # deno           # Deno section
  # ruby           # Ruby section
  # python         # Python section
  # red            # Red section
  # elm            # Elm section
  # elixir         # Elixir section
  # xcode          # Xcode section
  # xcenv          # xcenv section
  # swift          # Swift section
  # swiftenv       # swiftenv section
  # golang         # Go section
  # perl           # Perl section
  # php            # PHP section
  # rust           # Rust section
  # haskell        # Haskell Stack section
  # scala          # Scala section
  # kotlin         # Kotlin section
  # java           # Java section
  # lua            # Lua section
  # dart           # Dart section
  # julia          # Julia section
  # crystal        # Crystal section
  # docker         # Docker section
  # docker_compose # Docker section
  # aws            # Amazon Web Services section
  # gcloud         # Google Cloud Platform section
  # azure          # Azure section
  # venv           # virtualenv section
  # conda          # conda virtualenv section
  # uv             # uv virtualenv section
  # dotnet         # .NET section
  # ocaml          # OCaml section
  # vlang          # V section
  zig            # Zig section
  # purescript     # PureScript section
  # erlang         # Erlang section
  # gleam          # Gleam section
  # kubectl        # Kubectl context section
  # ansible        # Ansible section
  # terraform      # Terraform workspace section
  # pulumi         # Pulumi stack section
  # ibmcloud       # IBM Cloud section
  nix_shell      # Nix shell
  gnu_screen     # GNU Screen section
  exec_time      # Execution time
  # async          # Async jobs indicator
  # line_sep       # Line break
  battery        # Battery level and status
  jobs           # Background jobs indicator
  exit_code      # Exit code section
  sudo           # Sudo indicator
  char           # Prompt character
)

SPACESHIP_CHAR_SYMBOL=$'\n$ '

. "$ZDOTDIR/spaceship-prompt/spaceship.zsh"

bindkey -e                                        # emacs key bindings
bindkey ' ' magic-space                           # do history expansion on space
bindkey '^U' backward-kill-line                   # ctrl + U
bindkey '^[[3;5~' kill-word                       # ctrl + Supr
bindkey '^[[3~' delete-char                       # delete
bindkey '^[[1;5C' forward-word                    # ctrl + ->
bindkey '^[[1;5D' backward-word                   # ctrl + <-
bindkey '^[[5~' beginning-of-buffer-or-history    # page up
bindkey '^[[6~' end-of-buffer-or-history          # page down
bindkey '^[[H' beginning-of-line                  # home
bindkey '^[[F' end-of-line                        # end
bindkey '^[[Z' undo                               # shift + tab undo last action

export EDITOR=vim

# History configurations
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=2000
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
#setopt share_history         # share command history data

# force zsh to show the complete history
alias history="history 0"

autoload -U compinit && compinit
zstyle ':completion:*' menu select

# TODO: marlonrichert/zsh-autocomplete ?
# TODO: z-shell/zsh-select / fzf

pdf_gs() {
    local prefix=""
    if [[ "$1" != *'.pdf' ]]; then
        prefix="$1"
        echo "prefix: ${prefix}"
        shift
    fi

    # Extract the file extension and the base name without the extension
    local filepath="$1"
    local filedir="${filepath:h}"
    local filename="${filepath:t}"
    local extension="${filename##*.}"
    local basename="${filename%.*}"

    #echo "filepath: $filepath"
    #echo "filedir: $filedir"
    #echo "filename: $filename"
    #echo "extension: $extension"
    #echo "basename: $basename"

    # Check if the file extension is 'pdf'
    if [[ "$extension" != "pdf" ]]; then
        echo "Error: The file is not a PDF."
        return 1
    fi

    set -x
    gs -sOutputFile="${filedir}/${prefix}${basename}_gs.pdf" -sDEVICE=pdfwrite -sColorConversionStrategy=Gray -dProcessColorModel=/DeviceGray -dCompatibilityLevel=1.4 -dNOPAUSE -dBATCH "${filepath}"
    ret="$?"
    set +x
    return "$ret"
}

if [ -f "$ZDOTDIR/.zshrc_local" ]; then
  . "$ZDOTDIR/.zshrc_local"
fi
