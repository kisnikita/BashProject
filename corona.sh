#! /bin/sh
export POSIXLY_CORRECT=yes

print_graph_default()
{
  INPUT=$1
  WIDTH=$2
  echo "$INPUT" | awk \
              -F': ' \
              -v width=$WIDTH \
              '{
                  i = $2
                  printf "%s: ", $1
                  while(i >= width)
                  {
                    printf "#"
                    i -= width
                  }
                  printf "\n"
              }'
}
print_graph_custom()
{
  INPUT=$1
  WIDTH=$2
  MAX_VALUE=$(echo "$INPUT" | awk \
              -F': ' \
              -v width=$WIDTH \
              'BEGIN{max_value = $2}
              {
                  if($2 > max_value)
                  {
                      max_value = $2
                  }
              }END{print max_value}')
  if [ $WIDTH -eq 0 ] || [ -z $MAX_VALUE ]; then
        print_graph_default "$INPUT" "99999999999"
        exit 0
  fi
    echo "$INPUT" | awk \
                -F': ' \
                -v width=$WIDTH \
                -v max_value=$MAX_VALUE \
                '{
                    i = ($2 / max_value) * width
                    printf "%s: ", $1
                    while(i >= 1)
                    {
                      printf "#"
                      i -= 1
                    }
                    printf "\n"
                }'
}
check_date()
{
  DATE=$1
  DATE_PATTERN="$2"
  IS_CORRECT=$(echo "$DATE" | \
   awk -v date_pattern="$DATE_PATTERN" \
    '{if($0 !~ date_pattern){print "0"}else{print "1"}}')
  if [ "$IS_CORRECT" -ne 1 ]; then
      echo "Wrong date format! (Correct is YYYY-MM-DD)" >/dev/stderr
      exit 3
  fi
}


COMMAND=""
GZ_LOG_FILES=""
LOG_FIlES=""

DATE_PATTERN="^ *[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01]) *$"

AVAILABLE_COMMANDS="infected merged gender age daily monthly yearly countries districts regions"
while [ "$#" -gt 0 ]; do
    case "$1" in
    infected|merge|gender|age|daily|monthly|yearly|countries|districts|regions)
      COMMAND="$1"
      shift
      ;;
    -h)
      echo "help"
      exit 0
      ;;
    -s)
      #checks if value of -s is specified
      CHECK=$(echo $2 | grep -Eo "[0-9]*")
      if [ "$CHECK" = "$2" -a "$CHECK" != "" ]; then
          IS_WIDTH_SET=1
          WIDTH=$2
          shift
      fi
      GRAPH_MOD="1"
      shift
      ;;
    -a)
      check_date "$2" "$DATE_PATTERN"
      AFTER="$2"
      shift
      shift
      ;;
    -b)
      check_date "$2" "$DATE_PATTERN"
      BEFORE="$2"
      shift
      shift
      ;;
    -g)
      if [ "$2" != "M" ] && [ "$2" != "Z" ]; then
          echo "Wrong gender format!(M or Z)" >/dev/stderr
          exit 4
      fi
      GENDER="$2"
      shift
      shift
      ;;
    *)
      if [ -f "$1" ]; then
        if file "$1" | grep -q compressed; then
          GZ_LOG_FILES="$1 $GZ_LOG_FILES"
        else
          LOG_FIlES="$1 $LOG_FIlES"
        fi
      else
        echo "File \"$1\" doesn't exist." >/dev/stderr
        exit 2
      fi
      shift
      ;;
    esac
done

if [ -z $GZ_LOG_FILES ] ; then
    READ_INPUT="cat $LOG_FIlES"
else
    READ_INPUT="gzip -d -c $GZ_LOG_FILES | cat $LOG_FIlES -"
fi

if [ "$READ_INPUT" = "" ]; then
    READ_INPUT <&0
fi

VALIDATE_INPUT="$READ_INPUT | \
                awk \
                -F',' \
                -v date_pattern="\""\$DATE_PATTERN"\""
                '{
                  if(\$4 == "\""pohlavi"\"" || \$2 == "\"""\""){
                    NR = NR + 1
                  } else if(\$2 !~ date_pattern)
                  {
                      print "\""Invalid date: "\""\$0 > "\""/dev/stderr"\""
                  } else if(\$3 !~ /^ *[0-9]{1,3} *$/ && \$3 != "\"""\"")
                  {
                      print "\""Invalid age: "\""\$0 > "\""/dev/stderr"\""
                  } else
                  {
                      print \$0
                  }
                }'
"

FILTERED_INPUT="eval $VALIDATE_INPUT | \
                awk \
                -v before=$BEFORE \
                -v after=$AFTER \
                -v gender=$GENDER \
                -F',' \
                '{
                  if((\$2 <= before || before == "\"""\"") &&
                     (\$2 >= after || after == "\"""\"") &&
                     (\$4 == gender || gender == "\"""\""))
                  {
                      print \$0
                  }
                }'
"

case $COMMAND in
infected)
      OUTPUT=$($FILTERED_INPUT | \
          awk \
          -F',' \
          '{
              count++
          } END {
            print count
          }')
      echo "$OUTPUT"
      exit 0
  ;;
gender)

  OUTPUT=$($FILTERED_INPUT | \
      awk \
      -F',' \
      '{
        if($4=="M")
          MAN++;
        else if($4=="Z")
          WOMAN++;
        else
          NONE++
      } END {
        printf "M: %s\nW: %s\n", MAN, WOMAN
        if(NONE > 0){
          printf "None: %s\n", NONE
        }
      }')
  WIDTH_DEFAULT=100000
  ;;
age)
  OUTPUT=$($FILTERED_INPUT | \
            awk \
            -F',' \
            '{
              if($3 == "")
                age_none++
              else if($3 <= 5)
                age_0_5++;
              else if($3 <= 15)
                age_6_15++;
              else if($3 <= 25)
                age_16_25++;
              else if($3 <= 35)
                age_26_35++;
              else if($3 <= 45)
                age_36_45++;
              else if($3 <= 55)
                age_46_55++;
              else if($3 <= 65)
                age_56_65++;
              else if($3 <= 75)
                age_66_75++;
              else if($3 <= 85)
                age_76_85++;
              else if($3 <= 95)
                age_86_95++;
              else if($3 <= 105)
                age_96_105++;
              else
                age_106_200++;
            } END {
              print "0-5   :", age_0_5
              print "6-15  :", age_6_15
              print "16-25 :", age_16_25
              print "26-35 :", age_26_35
              print "36-45 :", age_36_45
              print "46-55 :", age_46_55
              print "56-65 :", age_56_65
              print "66-75 :", age_66_75
              print "76-85 :", age_76_85
              print "86-95 :", age_86_95
              print "96-105:", age_96_105
              print ">105  :", age_106_200
              print "None  :", age_none
            }')
    WIDTH_DEFAULT=10000
  ;;
daily)
    OUTPUT=$($FILTERED_INPUT | \
        awk \
        -F',' \
        '{
          days[$2]++
        } END {
          for(day in days)
          {
            print day ":", days[day]  | "sort"
          }
        }')
    WIDTH_DEFAULT=500
  ;;
monthly)
    OUTPUT=$($FILTERED_INPUT | \
        awk \
        -F',' \
        '{
          $2 = substr($2, 0, 7)
          monthes[$2]++
        } END {
          for(month in monthes)
          {
            print month ":", monthes[month]  | "sort"
          }
        }')
    WIDTH_DEFAULT=10000
  ;;
yearly)
    OUTPUT=$($FILTERED_INPUT | \
        awk \
        -F',' \
        '{
          $2 = substr($2, 0, 4)
          years[$2]++
        } END {
          for(year in years)
          {
            print year ":", years[year]  | "sort"
          }
        }')
    WIDTH_DEFAULT=100000
  ;;
countries)
    OUTPUT=$($FILTERED_INPUT | \
        awk \
        -F',' \
        '{
          if($7 == 1)
          {
            countries[$8]++
          }
        } END {
          for(country in countries)
          {
            print country ":", countries[country]  | "sort"
          }
        }')
    WIDTH_DEFAULT=100
  ;;
districts)
    OUTPUT=$($FILTERED_INPUT | \
        awk \
        -F',' \
        '{
            if($6 == ""){
              districts["None"]++
              next
            }
            districts[$6]++
        } END {
          for(district in districts)
          {
            print district ":", districts[district]  | "sort"
          }
        }')
    WIDTH_DEFAULT=1000
  ;;
regions)
    OUTPUT=$($FILTERED_INPUT | \
        awk \
        -F',' \
        '{
            if($5 == ""){
              regions["None"]++
              next
            }
            regions[$5]++
        } END {
          for(region in regions)
          {
            print region ":", regions[region]  | "sort"
          }
        }')
    WIDTH_DEFAULT=10000
  ;;
merge)
  echo "id,datum,vek,pohlavi,kraj_nuts_kod,okres_lau_kod,nakaza_v_zahranici,nakaza_zeme_csu_kod,reportovano_khs"
  eval $FILTERED_INPUT
  exit 0
  ;;
"")
  echo "id,datum,vek,pohlavi,kraj_nuts_kod,okres_lau_kod,nakaza_v_zahranici,nakaza_zeme_csu_kod,reportovano_khs"
  eval $FILTERED_INPUT
  exit 0
  ;;
esac

if [ "$GRAPH_MOD" = "1" ]; then
  if [ "$IS_WIDTH_SET" = "1" ]; then
    print_graph_custom "$OUTPUT" "$WIDTH"
  else
    print_graph_default "$OUTPUT" "$WIDTH_DEFAULT"
  fi
else
  echo "$OUTPUT"
fi