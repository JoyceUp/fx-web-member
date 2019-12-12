function str2display(para){
	switch(para){
	case undefined:
		return "";
	default:
		return para;
	}
}
function canFillHTML(power2vali,powerAttr,htmlStr){
	if(canDo(power2vali,powerAttr)){
		return htmlStr;
	}
	return "";
}
function canDo(power2vali,powerAttr){
	if((power2vali&powerAttr) == powerAttr){
		return true;
	}
	return false;
}

function getImages(who,id){
	var id = String(id)
	if(id && id != '' && $(who)[0].src.indexOf("pic.png") > 0){
        $.post("/common/images/",{id:id},function(result){
            if(result){
                $(who).attr("src",result)
            }
        });
	}

}

function loading(){
    var loadingIndex = layer.load(2, {
        shade: [0.6,'#fff'] //0.1透明度的白色背景
    });
}

function closeLoading(){
    layer.closeAll('loading');
}

//四舍五入
function toFixed(num, s) {
    var times = Math.pow(10, s + 1),
        des = parseInt(num * times),
        rest = des % 10;
    if (rest == 5) {
        return ((parseFloat(des) + 1) / times).toFixed(s);
    }
    return num.toFixed(s);
}