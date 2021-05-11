#!/bin/bash

# This script generates a HTML file which allows you to
# check English and translated man pages side-by-side.

JMREPO=$HOME/work/jm-work/jm
MAN2HTML=$JMREPO/admin/man-1.6g/man2html/man2html

if [ $# -lt 1 ]; then
    echo "Usage: $0 <draft> [<original>]"
    exit 1
fi

DRAFT_PAGE=$1
if [ $# -ge 2 ]; then
    ORIG_PAGE=$2
else
    ORIG_PAGE=$(echo $DRAFT_PAGE | sed -e 's/draft/original/')
fi

OUTPUT_FILE=jm-check-$(basename $DRAFT_PAGE).html

cat <<EOF > $OUTPUT_FILE
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD><TITLE>Man page of ERROR</TITLE>
<link rel="stylesheet" type="text/css" href="../../www/jm.css">
<style>
  .box { display: flex; }
  .left  { width: 50%; padding: 10px; border-style: solid; border-width: 1px; }
  .right { width: 50%; padding: 10px; border-style: solid; border-width: 1px; }
</style>
</HEAD><BODY>
<div class="box">
<div class="left">
EOF

$MAN2HTML $ORIG_PAGE | tail +6 | grep -v '</BODY>' | grep -v '</HTML>' >> $OUTPUT_FILE

cat <<EOF >> $OUTPUT_FILE
</div>
<div class="right">
EOF

$MAN2HTML $DRAFT_PAGE | tail +6 | grep -v '</BODY>' | grep -v '</HTML>' >> $OUTPUT_FILE

cat <<EOF >> $OUTPUT_FILE
</div>
</div>
</BODY>
</HTML>
EOF

echo "$OUTPUT_FILE is genereated."
