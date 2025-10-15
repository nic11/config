export ZSH="$HOME/my/config/zsh/ohmyzsh"
ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh

export EDITOR=vim

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

if [ -f "$HOME/my/config/zsh/.zshrc_local" ]; then
  . "$HOME/my/config/zsh/.zshrc_local"
fi
