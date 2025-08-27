#!/usr/bin/env bash
# ops_and_reverse.sh
# Bash script to accept two user variables (int/real/string) and perform operations.

# Check for bc (for floating arithmetic)
if ! command -v bc >/dev/null 2>&1; then
  echo "Error: 'bc' is required but not installed. Install bc and re-run." >&2
  exit 1
fi

# reverse string function (uses 'rev' if available, otherwise uses awk)
reverse_str() {
  local s="$1"
  if command -v rev >/dev/null 2>&1; then
    printf "%s" "$s" | rev
  else
    # fallback: awk to reverse
    printf "%s" "$s" | awk '{ for(i=length;i>0;i--) printf("%s", substr($0,i,1)); }'
  fi
}

# type checking
is_int() { [[ $1 =~ ^[+-]?[0-9]+$ ]]; }
is_float() { [[ $1 =~ ^[+-]?([0-9]*\.[0-9]+|[0-9]+\.[0-9]*)$ ]]; }
is_number() { is_int "$1" || is_float "$1"; }

# format numeric output from bc: strip trailing zeros
format_num() {
  local val="$1"
  # Remove trailing zeros and trailing dot
  printf "%s" "$val" | sed -E 's/^(-)?\.([0-9])/\10.\2/; s/([0-9])?\.?0+$//; s/([0-9]+\.[0-9]*[1-9])0+$/\1/; s/\.?$//'
}

# repeat string n times (n must be non-negative integer)
repeat_str() {
  local s="$1"
  local n="$2"
  if (( n < 0 )); then
    echo "ERROR_REPEAT_NEGATIVE"
    return 1
  fi
  local out=""
  for ((i=0;i<n;i++)); do out+="$s"; done
  printf "%s" "$out"
}

while true; do
  echo "Enter value for userv1 (any type):"
  read -r userv1
  echo "Enter value for userv2 (any type):"
  read -r userv2

  # detect types
  if is_int "$userv1"; then type1="integer"
  elif is_float "$userv1"; then type1="real"
  else type1="string"; fi

  if is_int "$userv2"; then type2="integer"
  elif is_float "$userv2"; then type2="real"
  else type2="string"; fi

  echo
  echo "Detected types: userv1='$userv1' ($type1), userv2='$userv2' ($type2)"
  echo

  ######### ADDITION #########
  if is_number "$userv1" && is_number "$userv2"; then
    # numeric addition (use bc, coerce to float if either is float)
    sum=$(printf "scale=10; %s + %s\n" "$userv1" "$userv2" | bc -l)
    sum=$(format_num "$sum")
    echo "the sum of '$userv1' and '$userv2' is $sum"
  elif [[ $type1 == "string" && $type2 == "string" ]]; then
    # string concatenation
    echo "the sum (concatenation) of '$userv1' and '$userv2' is '${userv1}${userv2}'"
  else
    echo "Cannot add a numeric and a non-numeric value. (Addition supported: number+number; string+string (concatenation))."
  fi

  ######### MULTIPLICATION #########
  if is_number "$userv1" && is_number "$userv2"; then
    prod=$(printf "scale=10; %s * %s\n" "$userv1" "$userv2" | bc -l)
    prod=$(format_num "$prod")
    echo "the product of '$userv1' and '$userv2' is $prod"
  else
    # check string * integer repetition (either order)
    if [[ $type1 == "string" && $type2 == "integer" ]]; then
      # repeat userv1 userv2 times
      if (( userv2 < 0 )); then
        echo "Multiplication error: cannot repeat string negative times ($userv2)."
      else
        repeated=$(repeat_str "$userv1" "$userv2")
        echo "the product (string repeated) of '$userv1' and '$userv2' is '$repeated'"
      fi
    elif [[ $type2 == "string" && $type1 == "integer" ]]; then
      if (( userv1 < 0 )); then
        echo "Multiplication error: cannot repeat string negative times ($userv1)."
      else
        repeated=$(repeat_str "$userv2" "$userv1")
        echo "the product (string repeated) of '$userv1' and '$userv2' is '$repeated'"
      fi
    else
      echo "Multiplication not supported for types: $type1 * $type2 (supported: number*number, string*integer)."
    fi
  fi

  ######### SUBTRACTION #########
  if is_number "$userv1" && is_number "$userv2"; then
    diff=$(printf "scale=10; %s - %s\n" "$userv1" "$userv2" | bc -l)
    diff=$(format_num "$diff")
    echo "the difference of '$userv1' and '$userv2' (userv1 - userv2) is $diff"
  else
    echo "Subtraction cannot be performed: both operands must be numeric."
  fi

  ######### DIVISION #########
  if is_number "$userv1" && is_number "$userv2"; then
    # check divide by zero
    if [[ $(printf "%s\n" "$userv2" | sed -E 's/^[+-]0+(\.0+)?$/0/;t;d') == "" && $(printf "%s\n" "$userv2" | sed -E 's/^[+-]0+(\.0+)?$/0/' ) == "0" ]]; then
      # simple check, but easier is to use bc and check zero explicitly:
      if awk "BEGIN{exit !($userv2 == 0)}"; then
        echo "Division error: division by zero."
      else
        :
      fi
    fi
    # robust zero check:
    iszero=0
    if is_float "$userv2" || is_int "$userv2"; then
      # use awk numeric compare
      awk "BEGIN{ if ($userv2 == 0) exit 0; else exit 1 }"
      if [[ $? -eq 0 ]]; then iszero=1; fi
    fi

    if (( iszero == 1 )); then
      echo "Division error: division by zero."
    else
      quot=$(printf "scale=10; %s / %s\n" "$userv1" "$userv2" | bc -l)
      quot=$(format_num "$quot")
      echo "the quotient of '$userv1' and '$userv2' (userv1 / userv2) is $quot"
    fi
  else
    echo "Division cannot be performed: both operands must be numeric."
  fi

  ######### REVERSE PRINTING #########
  rev1=$(reverse_str "$userv1")
  rev2=$(reverse_str "$userv2")
  echo "Reversed values (each variable reversed): $rev1 / $rev2"
  echo "Reversed and swapped order: $rev2 / $rev1"

  echo
  # Ask whether to run again
  while true; do
    printf "Run again? (y/n): "
    read -r yn
    case "$yn" in
      [Yy]* ) echo; break ;;
      [Nn]* ) echo "Goodbye."; exit 0 ;;
      * ) echo "Please answer y or n." ;;
    esac
  done
done
