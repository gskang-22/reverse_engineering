function isSameSubnetCheck(ipaddrSource,ipaddrDest,mask)
{
    ipaddrSource_split = ipaddrSource.split(".");
    ipaddrDest_split = ipaddrDest.split(".");
    mask_split = mask.split(".");
    
    var sourip = new Array();
    var destip = new Array();
    var submask = new Array();
    var i = 0;
    for(i = 0; i < 4; i++)
    {
        sourip[i] = parseInt(ipaddrSource_split[i]);
        destip[i] = parseInt(ipaddrDest_split[i]);
        submask[i] = parseInt(mask_split[i]);
    }
    if(((sourip[0]&submask[0]) == (destip[0]&submask[0])) 
        && ((sourip[1]&submask[1]) == (destip[1]&submask[1])) 
        && ((sourip[2]&submask[2]) == (destip[2]& submask[2])) 
        && ((sourip[3]&submask[3]) == (destip[3]& submask[3]))) 
        return true;
    else 
        return false;
}



