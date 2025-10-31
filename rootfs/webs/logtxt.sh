#! /bin/sh
awk '
BEGIN{
    FS="["
    la["em"] = 0
    la["al"] = 1
    la["cr"] = 2
    la["er"]   = 3
    la["wa"]  = 4
    la["no"]= 5
    la["in"]  = 6
    la["de"] = 7
    
    ld["Emergency"]=0
    ld["Alert"]=1
    ld["Critical"]=2
    ld["Error"]=3
    ld["Warning"]=4
    ld["Notice"]=5
    ld["Informational"]=6
    ld["Debug"]=7
}
{
    #split($3,s,".")
    if(la[substr($2,0,2)]<=ld[level]){
        print $0,"\r"
    }
}
' $1 -v level=$2
rm $1 

