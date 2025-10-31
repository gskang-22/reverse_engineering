function CheckAliveTime(data){
	if(isNaN(data)){
		return false;
	}else if(parseInt(data)<5 || parseInt(data)>60){
			return false;
	}
	return true;
}
function CheckAliveRetry(data){
        if(isNaN(data)){
                return false;
        }else if(parseInt(data)<1 || parseInt(data)>10){
                return false;
        }
        return true;
}


