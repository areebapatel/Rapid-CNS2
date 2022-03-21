#!/usr/bin/bash
for i in "$@"; do
  case $i in
    -s=*|--summary_file=*)
      SUMMARY_FILE="${i#*=}"
      shift #sequencing_summary.txt file in the guppy folder
      ;;
    -o=*|--out_html=*)
      OUT_HTML="${i#*=}"
      shift # path to output html
      ;;
    -t=*|--title=*)
      TITLE="${i#*=}"
      shift # title for html file. 
      ;;
  esac
done


pycoQC -f $SUMMARY_FILE  -o $OUT_HTML --report_title $TITLE -v
