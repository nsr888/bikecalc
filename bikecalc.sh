#!/bin/bash
#
# Script to calculate gear inches for a bicycle
# based on rim diameter, tire diameter, chainring and cog sizes
# and display the results in a table.

set -e          # Exit immediately if a command exits with a non-zero status
set -o pipefail # Return value of the last command to exit with a non-zero status
set -o nounset  # Treat unset variables as an error

# Default values
readonly default_first_chainring=22
readonly default_second_chainring=32
readonly default_third_chainring=44
readonly default_min_cog=11
readonly default_max_cog=32
readonly default_rim_diameter="584" # Default rim diameter in micrometers (650b/27.5)
readonly default_tire_width="57.15" # Default tire diameter in micrometers (2.25inch)
readonly column_width=10
readonly color_green="\e[32m"
readonly color_blue="\e[34m"
readonly color_red="\e[31m"
readonly color_reset="\e[0m"
readonly border_top_left="+"
readonly border_horizontal="-"
readonly border_top_right="+"
readonly border_left="|"
readonly border_right="|"
readonly border_bottom_left="+"
readonly border_bottom_right="+"
readonly inch=25.4

# CSV formatted strings for rim diameters in mm
rim_diameter_csv="rim diameter in mm,description
635,28inch
630,27inch
622,700c/29er
584,650b/27.5
571,650c
559,26inch
547,24inch-S5
540,24inch-E6
520,24inch-Terry
507,24inch-MTB/BMX
451,20inch-Recumbent
419,20inch-Schwinn
406,20inch-BMX/Recumb
369,17inch
349,16inch-Brompton"

# CSV formatted strings for tire widths in mm
tire_width_csv="tire width in mm,description
20,20mm
23,23mm
25,25mm
26,26mm
27,27mm
28,28mm
30,30mm
32,32mm
35,35mm
37,37mm
38,38mm
40,40mm
42,42mm
44,44mm
45,45mm
50,50mm
56,56mm
25.4,1.00inch
31.75,1.25inch
34.29,1.35inch
35.56,1.40inch
38.1,1.50inch
44.45,1.75inch
48.26,1.90inch
49.5,1.95inch
50.8,2.00inch
53.34,2.10inch
54,2.125inch
55.88,2.20inch
57.15,2.25inch
58.42,2.30inch
59.69,2.35inch
60.96,2.40inch
63.5,2.50inch
66.04,2.60inch
69.85,2.75inch
71.12,2.80inch
76.2,3.00inch
96.52,3.80inch
101.6,4.00inch
107.95,4.25inch
114.3,4.50inch
116.84,4.60inch
119.38,4.70inch
121.92,4.80inch
124.46,4.90inch"

# Check if Bash version is 4.4 or higher
check_bash_version() {
  local bash_version
  bash_version=$BASH_VERSION
  if [[ ${bash_version:0:1} -lt 4 || (${bash_version:0:1} -eq 4 && ${bash_version:2:1} -lt 4) ]]; then
    echo "This script requires Bash version 4.4 or higher." >>/dev/stderr
    exit 1
  fi
}

print_table_header() {
  local first_chainring=$1
  local second_chainring=$2
  local third_chainring=$3

  chainrings=("$first_chainring" "$second_chainring" "$third_chainring")
  column_count=$(echo "${#chainrings[@]}" + 1 | bc)
  top_char_count=$(echo "$column_count * ($column_width + 2) + $column_count - 1" | bc)

  printf "%s" "$border_top_left"
  for ((i = 0; i < top_char_count; i++)); do
    printf "%s" "$border_horizontal"
  done
  printf "%s\n" "$border_top_right"

  printf "%s %-${column_width}s " "$border_left" "Ring/Cog"
  for ch in "${chainrings[@]}"; do
    printf "| %-${column_width}s " "$ch"
  done
  printf "%s\n" "$border_right"

  printf "%s" "$border_left"
  for ((i = 0; i < top_char_count; i++)); do
    printf "%s" "$border_horizontal"
  done
  printf "%s\n" "$border_right"
}

# Create arrays for each column in the table
create_arrays() {
  local -n _first_column=$1
  local -n _second_column=$2
  local -n _third_column=$3
  local -n _fourth_column=$4

  local rim_diameter=$5
  local tire_width=$6
  local first_chainring=$7
  local second_chainring=$8
  local third_chainring=$9
  local min_cog=${10}
  local max_cog=${11}
  local wheel_diameter_inches
  local color

  # Calculate wheel diameter in inches
  wheel_diameter_inches=$(echo "scale=2; ($rim_diameter + $tire_width * 2) / $inch" | bc)

  for ((cog = min_cog; cog <= max_cog; cog++)); do
    _first_column+=("$cog")
    _second_column+=("$(echo "scale=2; $wheel_diameter_inches * ($first_chainring / $cog)" | bc)")
    _third_column+=("$(echo "scale=2; $wheel_diameter_inches * ($second_chainring / $cog)" | bc)")
    _fourth_column+=("$(echo "scale=2; $wheel_diameter_inches * ($third_chainring / $cog)" | bc)")
  done
}

# Print formatted table to the console
print_table() {
  local -n _first_arr=$1
  local -n _second_arr=$2
  local -n _third_arr=$3
  local -n _fourth_arr=$4
  local first_chainring=$5
  local second_chainring=$6
  local third_chainring=$7
  local min_cog=$8
  local max_cog=$9
  local wheel_diameter_inches
  local color

  print_table_header "$first_chainring" "$second_chainring" "$third_chainring"

  # Print table body
  for ((i = 0; i < ${#_first_arr[@]}; i++)); do
    printf "%s %-${column_width}s " "$border_left" "${_first_arr[i]}"
    for ch in ${_second_arr["$i"]} ${_third_arr[i]} ${_fourth_arr[i]}; do
      if (($(echo "$ch >= 80" | bc -l))); then
        color=$color_green # Green for 80 and above
      elif (($(echo "$ch >= 50" | bc -l))); then
        color=$color_blue # Blue for 50 to 79
      else
        color=$color_red # Red for below 50
      fi
      printf "| ${color}%-${column_width}s${color_reset} " "$ch"
    done
    printf "%s\n" "$border_right"
  done

  # Print table last line
  printf "%s" "$border_bottom_left"
  for ((i = 0; i < top_char_count; i++)); do
    printf "%s" "$border_horizontal"
  done
  printf "%s\n" "$border_bottom_right"
}

# Print summary of the input values
print_summary() {
  local rim_diameter=$1
  local tire_width=$2
  local first_chainring=$3
  local second_chainring=$4
  local third_chainring=$5
  local min_cog=$6
  local max_cog=$7

  echo "Summary:"
  echo "Rim diameter: $rim_diameter"
  echo "Tire diameter: $tire_width"
  echo "First chainring: $first_chainring"
  echo "Second chainring: $second_chainring"
  echo "Third chainring: $third_chainring"
  echo "Minimum cog: $min_cog"
  echo "Maximum cog: $max_cog"
}

# Common function to prompt for a positive integer value
prompt_value() {
  local value
  local value_name=$1
  local default_value=$2
  local max_value=$3

  while true; do
    read -r -p "Enter $value_name (optional, default: $default_value): " value
    value=${value:-$default_value}

    # check if value is a positive integer and not greater than max_value
    if [[ $value =~ ^[0-9]+$ && $value -le $max_value ]]; then
      break
    else
      echo "Invalid input. Please enter a positive integer less than or equal to $max_value." >>/dev/stderr
    fi
  done
  echo "$value"
}

# Prompt for a selection from a CSV formatted data
prompt_selection() {
  local prompt_message=$1
  local csv_data=$2
  local sort_order=$3
  local selection
  local sorted_data=()
  local data=()

  # Read CSV data into key-value pairs
  IFS=$'\n'
  for line in $(echo "$csv_data" | tail -n +2); do
    data+=("$line")
  done

  if [[ $sort_order == "asc" ]]; then
    mapfile -t sorted_data < <(printf "%s\n" "${data[@]}" | sort -t, -k1,1nr)
  elif [[ $sort_order == "desc" ]]; then
    # Reverse the order if sort_order is desc
    mapfile -t sorted_data < <(printf "%s\n" "${data[@]}" | sort -t, -k1,1n)
  else
    echo "Invalid sort order" >>/dev/stderr
    exit 1
  fi

  # Display the prompt message and options
  echo "$prompt_message" >>/dev/tty
  PS3="Enter your choice: "
  select opt in "${sorted_data[@]#*,}"; do
    if [[ -n $opt ]]; then
      for line in "${sorted_data[@]}"; do
        if [[ "${line#*,}" == "$opt" ]]; then
          selection=${line%%,*}
        fi
      done
      break
    else
      echo "Invalid choice" >>/dev/stderr
    fi
  done

  echo "$selection"
}

# Prompt for rim diameter from a list of options
prompt_rim_diameter() {
  prompt_selection "Select rim diameter:" "$rim_diameter_csv" "asc"
}

# Prompt for tire width from a list of options
prompt_tire_width() {
  prompt_selection "Select tire diameter:" "$tire_width_csv" "desc"
}

# Prompt user for input values
prompt_user() {
  local -n _rim_diameter=$1
  local -n _tire_width=$2
  local -n _first_chainring=$3
  local -n _second_chainring=$4
  local -n _third_chainring=$5
  local -n _min_cog=$6
  local -n _max_cog=$7

  _rim_diameter=$(prompt_rim_diameter)
  _rim_diameter=${_rim_diameter:-$default_rim_diameter} # Set default value if not provided

  _tire_width=$(prompt_tire_width)
  _tire_width=${_tire_width:-$default_tire_width} # Set default value if not provided

  _first_chainring=$(prompt_value "first chainring" $default_first_chainring 100)
  _second_chainring=$(prompt_value "second chainring" $default_second_chainring 100)
  _third_chainring=$(prompt_value "third chainring" $default_third_chainring 100)

  while true; do
    _min_cog=$(prompt_value "minimum cog" $default_min_cog 100)
    _max_cog=$(prompt_value "maximum cog" $default_max_cog 100)
    if [[ $_min_cog -le $_max_cog ]]; then
      break
    else
      echo "Invalid input. Minimum cog should be less than or equal to maximum cog." >>/dev/stderr
    fi
  done
}

# Main script execution
main() {
  check_bash_version
  prompt_user rim_diameter tire_width first_chainring second_chainring third_chainring min_cog max_cog
  create_arrays first_column second_column third_column fourth_column "$rim_diameter" "$tire_width" "$first_chainring" "$second_chainring" "$third_chainring" "$min_cog" "$max_cog"
  print_summary "$rim_diameter" "$tire_width" "$first_chainring" "$second_chainring" "$third_chainring" "$min_cog" "$max_cog"
  print_table first_column second_column third_column fourth_column "$first_chainring" "$second_chainring" "$third_chainring" "$min_cog" "$max_cog"
}

main
