#! /bin/sh
awk '
{
   
        print $0,"\r"
    
}
' $1 
#rm $1 
