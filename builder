#!/usr/bin/env bash
safe_export() {
local var_name=""
local default_value=""
local is_array=false
while [[ $# -gt 0 ]];do
case "$1" in
--name|-n) var_name="$2";shift 2;;
--default|-d) default_value="$2";shift 2;;
--array|-a) is_array=true;shift;;
*) echo "Parámetro desconocido: $1" >&2;return 1;;
esac
done
[[ -z "$var_name" ]]&&{ echo "Falta nombre de variable" >&2;return 1;}
[[ -v $var_name ]]&&return
if $is_array;then
eval "export $var_name=($default_value)"
else
eval "export $var_name=\"$default_value\""
fi
}
safe_declare() {
local var_name=""
local default_value=""
local type_flag=""
while [[ $# -gt 0 ]];do
case "$1" in
--name|-n) var_name="$2";shift 2;;
--default|-d) default_value="$2";shift 2;;
--array|-a) type_flag="-a";shift;;
--assoc|-A) type_flag="-A";shift;;
*) echo "Parámetro desconocido: $1" >&2;return 1;;
esac
done
[[ -z "$var_name" ]]&&{ echo "Falta nombre de variable" >&2;return 1;}
[[ -v $var_name ]]&&return
if [[ "$type_flag" == "-a"||"$type_flag" == "-A" ]];then
if [[ -z "$default_value" ]];then
eval "declare -g $type_flag $var_name=()"
else
eval "declare -g $type_flag $var_name=($default_value)"
fi
else
eval "declare -g $var_name=\"$default_value\""
fi
}
RED="\033[0;31m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RESET="\033[0m"
color.red() {
echo -e "$RED$1$RESET"
}
color.blue() {
echo -e "$BLUE$1$RESET"
}
color.cyan() {
echo -e "$CYAN$1$RESET"
}
color.green() {
echo -e "$GREEN$1$RESET"
}
color.yellow() {
echo -e "$YELLOW$1$RESET"
}
message(){ printf "%s $1\n" '--';}
error.log(){ message "$RED$1$RESET";}
info.log(){ message "$GREEN$1$RESET";}
debug.log(){ message "$BLUE$1$RESET";}
error() {
error.log "Error: $1"
exit 1
}
help.description() {
safe_declare --name HELP_DESCRIPTION --default "$1"
}
safe_declare --name HELP_TYPES --assoc
safe_declare --name HELP_COMMANDS --assoc
safe_declare --name HELP_DESCRIPTIONS --assoc
HELP_INDEX=0
help.add_option() {
local command="$1"
local description="$2"
local type="${3:-General}"
local key="opt_$HELP_INDEX"
((HELP_INDEX++))
HELP_COMMANDS[$key]="$command"
HELP_DESCRIPTIONS[$key]="$description"
HELP_TYPES[$type]+="$key "
}
help.show_description() {
printf "$HELP_DESCRIPTION\n\n"
}
help.show() {
help.show_description
printf "${GREEN}Usage:$RESET $CYAN$(basename $0) [OPTIONS]$RESET\n\n"
if [[ -n "${HELP_TYPES[General]}" ]];then
printf "${GREEN}General options:$RESET\n"
for key in ${HELP_TYPES[General]};do
printf " $CYAN${HELP_COMMANDS[$key]}$RESET ${HELP_DESCRIPTIONS[$key]}\n"
done
echo
fi
for type in "${!HELP_TYPES[@]}";do
if [[ "$type" != "General" ]];then
printf "${GREEN}$type options:$RESET\n"
for key in ${HELP_TYPES[$type]};do
printf " $CYAN${HELP_COMMANDS[$key]}$RESET ${HELP_DESCRIPTIONS[$key]}\n"
done
echo
fi
done
}
minify.file() {
local input="$1"
local output="${2:-}"
if [[ ! -f "$input" ]];then
echo "[minify] Error: fichero no encontrado: $input" >&2
return 1
fi
if [[ -n "$output" ]];then
if [[ "$(realpath "$input")" == "$(realpath "$output")" ]];then
local tmp
tmp="$(mktemp)"
_minify_stream < "$input" > "$tmp"
mv "$tmp" "$output"
else
_minify_stream < "$input" > "$output"
fi
else
_minify_stream < "$input"
fi
}
_minify_stream() {
local shebang=""
local lines=()
local line trimmed
local in_heredoc=false
local heredoc_delimiter=""
while IFS= read -r line||[[ -n "$line" ]];do
lines+=("$line")
if [[ -z "$shebang"&&"$line" =~ ^[[:space:]]*#!/ ]];then
trimmed="${line#"${line%%[![:space:]]*}"}"
shebang="$trimmed"
fi
done
[[ -z "$shebang" ]]&&shebang="#!/bin/bash"
printf '%s\n' "$shebang"
for line in "${lines[@]}";do
if $in_heredoc;then
printf '%s\n' "$line"
trimmed_close="${line#"${line%%[![:space:]]*}"}"
trimmed_close="${trimmed_close%"${trimmed_close##*[![:space:]]}"}"
if [[ "$trimmed_close" == "$heredoc_delimiter" ]];then
in_heredoc=false
fi
continue
fi
trimmed="${line#"${line%%[![:space:]]*}"}"
trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"
[[ "$trimmed" =~ ^#!/ ]]&&continue
[[ -z "$trimmed" ]]&&continue
[[ "$trimmed" == "#"* ]]&&continue
if [[ "$trimmed" =~ \<\<-?[[:space:]]*['"']?([a-zA-Z0-9_]+)['"']? ]];then
in_heredoc=true
heredoc_delimiter="${BASH_REMATCH[1]}"
fi
_squeeze_line "$trimmed"
done
}
_squeeze_line() {
printf '%s\n' "$1"|sed -E \
-e 's/^function[[:space:]]+([a-zA-Z_][a-zA-Z0-9_.]*)[[:space:]]*\{/\1()\{/' \
-e 's/^function[[:space:]]+//' \
-e 's/[[:space:]]*\|\|[[:space:]]*/||/g' \
-e 's/[[:space:]]*\|[[:space:]]*/|/g' \
-e 's/[[:space:]]*&&[[:space:]]*/\&\&/g' \
-e 's/[[:space:]]*;[[:space:]]*/;/g' \
-e 's/[[:space:]]*;;[[:space:]]*/;;/g' \
-e 's/(<<<)[[:space:]]+/\1/g' \
-e 's/([^"''\\])[[:space:]]{2,}/\1 /g'
}
BB_VERSION=1.0.1
help.description "Bash Builder (v$BB_VERSION)\n-----------------------------------\nAuthor: Miguel Albors Iruretagoyena\nSource: https://git.yawin.es/personal/bash-builder\nLicense: GNU GPLv3\n\nUtility to bundle bash scripts"
help.add_option "-h " "Print this help menu"
help.add_option "-e <path>" "The entrypoint to the bash script to bundle"
help.add_option "-o <path>" "The output file to write to"
help.add_option "-m " "Minify the output file (default: false)"
safe_declare --name included_files --assoc
SHEBANG_LINE=""
SHEBANG_PRINTED=false
bundle_script() {
local file="$1"
if [[ -n "${included_files[$file]}" ]];then
echo "# [SKIPPED] $file already included"
return
fi
included_files["$file"]=1
if ! $SHEBANG_PRINTED;then
SHEBANG_PRINTED=true
if [[ -n "$SHEBANG_LINE" ]];then
echo "$SHEBANG_LINE"
fi
fi
echo "# === BEGIN $file ==="
keyword="s""ource"
while IFS= read -r line||[[ -n "$line" ]];do
if [[ "$line" =~ ^[[:space:]]*($keyword|\.)[[:space:]]+([^ ]+) ]];then
local src_file="${BASH_REMATCH[2]}"
local dir="$(dirname "$file")"
local full_path="$(realpath "$dir/$src_file")"
bundle_script "$full_path"
else
if [[ "$line" =~ ^[[:space:]]*#!/ ]];then
[[ -z "$SHEBANG_LINE" ]]&&SHEBANG_LINE="$line"
continue
fi
echo "$line"
fi
done < "$file"
echo "# === END $file ==="
}
ENTRY=${ENTRY:-}
OUTPUT=${OUTPUT:-}
MINIFY=${MINIFY:-0}
while getopts :he:o:m opt;do
case $opt in
h)
help.show
exit 0
;;
e) ENTRY=${OPTARG:-$ENTRY};;
o) OUTPUT=${OPTARG:-$OUTPUT};;
m) MINIFY=1;;
?)
printf "$RED[!]$RESET $(basename $0): illegal option -- $OPTARG\n\n"
help.show
exit 1
;;
:)
printf "$RED[!]$RESET $(basename $0): option requires an argument -- $OPTARG\n\n"
help.show
exit 1
;;
esac
done
main_script="$(realpath "$ENTRY")"
out_script="$(realpath "$OUTPUT")"
if [[ ! -f "$main_script" ]];then
error.log "Input file not specified or invalid"
exit 2
fi
if [[ -z $out_script ]];then
error.log "Output file not specified or invalid"
exit 3
fi
if IFS= read -r first_line < "$main_script"&&[[ "$first_line" =~ ^#!/ ]];then
SHEBANG_LINE="$first_line"
fi
message "$BLUE Building:$RESET $main_script"
bundle_script "$main_script" > $out_script
if [[ -n "$SHEBANG_LINE" ]];then
read -r output_first_line < "$out_script"
if [[ ! "$output_first_line" =~ ^#!/ ]];then
local tmp_header
tmp_header="$(mktemp)"
echo "$SHEBANG_LINE"|cat - "$out_script" > "$tmp_header"
mv "$tmp_header" "$out_script"
fi
fi
if [[ $MINIFY -eq 1 ]];then
message "$BLUE Minifying:$RESET $out_script"
minify.file "$out_script" "$out_script"
fi
info.log "Completed successfully!"
