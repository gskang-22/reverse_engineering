#! /bin/sh
echo "Content-type:text/html;charset=UTF-8"
echo "Cache-Control:private,max-age=0;"
echo 
awk '
#BEGIN{ print "<table border=1>" }
#END{ print "</table>" }
{
    if(NF < 7) next; 
	print "<tr>"

	#print "<td>",NR,"</td>"
	print "<td>",$1,$2,"</td>"
    split($3,s,".")
	print "<td>",s[1],"</td>"
	print "<td>",s[2],"</td>"
	$1=$2=$3=""
	print "<td>",$0,"</td>"

	print "</tr>"
}
' $1
#rm $1
