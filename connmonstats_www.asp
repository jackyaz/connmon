<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">
<link rel="shortcut icon" href="images/favicon.png">
<link rel="icon" href="images/favicon.png">
<title>Internet Uptime Monitoring</title>
<link rel="stylesheet" type="text/css" href="index_style.css">
<link rel="stylesheet" type="text/css" href="form_style.css">
<style>
p {
  font-weight: bolder;
}

.collapsible {
  color: white;
  padding: 0px;
  width: 100%;
  border: none;
  text-align: left;
  outline: none;
  cursor: pointer;
}

.collapsible-jquery {
  color: white;
  padding: 0px;
  width: 100%;
  border: none;
  text-align: left;
  outline: none;
  cursor: pointer;
}

.collapsiblecontent {
  padding: 0px;
  max-height: 0;
  overflow: hidden;
  border: none;
  transition: max-height 0.2s ease-out;
}

.invalid {
  background-color: darkred !important;
}
</style>
<script language="JavaScript" type="text/javascript" src="/js/jquery.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/moment.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chart.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/hammerjs.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chartjs-plugin-zoom.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chartjs-plugin-annotation.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chartjs-plugin-datasource.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chartjs-plugin-deferred.js"></script>
<script language="JavaScript" type="text/javascript" src="/state.js"></script>
<script language="JavaScript" type="text/javascript" src="/general.js"></script>
<script language="JavaScript" type="text/javascript" src="/popup.js"></script>
<script language="JavaScript" type="text/javascript" src="/help.js"></script>
<script language="JavaScript" type="text/javascript" src="/tmhist.js"></script>
<script language="JavaScript" type="text/javascript" src="/tmmenu.js"></script>
<script language="JavaScript" type="text/javascript" src="/client_function.js"></script>
<script language="JavaScript" type="text/javascript" src="/validator.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/connmon/connstatsdata.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/connmon/connstatstext.js"></script>
<script>
// Keep the real data in a seperate object called allData
// Put only that part of allData in the dataset to optimize zoom/pan performance
// Author: Evert van der Weit - 2018

function filterData(chartInstance) {
	var datasets = chartInstance.data.datasets;
	var originalDatasets = chartInstance.data.allData;
	var chartOptions = chartInstance.options.scales.xAxes[0];
	
	var startX = chartOptions.time.min;
	var endX = chartOptions.time.max;
	if(typeof originalDatasets === 'undefined' || originalDatasets === null) { return; }
	for(var i = 0; i < originalDatasets.length; i++) {
		var dataset = datasets[i];
		var originalData = originalDatasets[i];
		
		if (!originalData.length) break
		
		var s = startX;
		var e = endX;
		var sI = null;
		var eI = null;
		
		for (var j = 0; j < originalData.length; j++) {
			if ((sI==null) && originalData[j].x > s) {
				sI = j;
			}
			if ((eI==null) && originalData[j].x > e) {
				eI = j;
			}
		}
		if (sI==null) sI = 0;
		if (originalData[originalData.length - 1].x < s) eI = 0
			else if (eI==null) eI = originalData.length
		
		dataset.data = originalData.slice(sI, eI);
	}
}

var datafilterPlugin = {
	beforeUpdate: function(chartInstance) {
		filterData(chartInstance);
	}
}
</script>
<script>
var ShowLines=GetCookie("ShowLines");
var ShowFill=GetCookie("ShowFill");
Chart.defaults.global.defaultFontColor = "#CCC";
Chart.Tooltip.positioners.cursor = function(chartElements, coordinates) {
	return coordinates;
};

var custom_settings;

function LoadCustomSettings(){
	custom_settings = <% get_custom_settings(); %>;
	for (var prop in custom_settings) {
		if (Object.prototype.hasOwnProperty.call(custom_settings, prop)) {
			if(prop.indexOf("connmon") != -1){
				eval("delete custom_settings."+prop)
			}
		}
	}
}

var metriclist = ["Ping","Jitter","Packet_Loss"];
var titlelist = ["Ping","Jitter","Quality"];
var measureunitlist = ["ms","ms","%"];
var chartlist = ["daily","weekly","monthly"];
var timeunitlist = ["hour","day","day"];
var intervallist = [24,7,30];
var colourlist = ["#fc8500","#42ecf5","#ffffff"];

function keyHandler(e) {
	if (e.keyCode == 27){
		$(document).off("keydown");
		ResetZoom();
	}
}

$(document).keydown(function(e){keyHandler(e);});
$(document).keyup(function(e){
	$(document).keydown(function(e){
		keyHandler(e);
	});
});

function Validate_IP(forminput){
	var inputvalue = forminput.value;
	var inputname = forminput.name;
	if(/^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test(inputvalue)){
			$(forminput).removeClass("invalid");
			return true;
	}
	else{
		$(forminput).addClass("invalid");
		return false;
	}
}

function Validate_All(){
	var validationfailed = false;
	if(! Validate_IP(eval("document.form.connmon_ipaddr"))){validationfailed=true;}
	if(! Validate_Domain(eval("document.form.connmon_domain"))){validationfailed=true;}
	
	if(validationfailed){
		alert("Validation for some fields failed. Please correct invalid values and try again.");
		return false;
	}
	else{
		return true;
	}
}

function Draw_Chart_NoData(txtchartname){
	document.getElementById("divLineChart"+txtchartname).width="730";
	document.getElementById("divLineChart"+txtchartname).height="300";
	document.getElementById("divLineChart"+txtchartname).style.width="730px";
	document.getElementById("divLineChart"+txtchartname).style.height="300px";
	var ctx = document.getElementById("divLineChart"+txtchartname).getContext("2d");
	ctx.save();
	ctx.textAlign = 'center';
	ctx.textBaseline = 'middle';
	ctx.font = "normal normal bolder 48px Arial";
	ctx.fillStyle = 'white';
	ctx.fillText('No data to display', 365, 150);
	ctx.restore();
}

function Draw_Chart(txtchartname,txttitle,txtunity,txtunitx,numunitx,colourname){
	var objchartname=window["LineChart"+txtchartname];
	var objdataname=window[txtchartname+"size"];
	if(typeof objdataname === 'undefined' || objdataname === null) { Draw_Chart_NoData(txtchartname); return; }
	if (objdataname == 0) { Draw_Chart_NoData(txtchartname); return; }
	
	factor=0;
	if (txtunitx=="hour"){
		factor=60*60*1000;
	}
	else if (txtunitx=="day"){
		factor=60*60*24*1000;
	}
	if (objchartname != undefined) objchartname.destroy();
	var ctx = document.getElementById("divLineChart"+txtchartname).getContext("2d");
	var lineOptions = {
		segmentShowStroke : false,
		segmentStrokeColor : "#000",
		animationEasing : "easeOutQuart",
		animationSteps : 100,
		/*animation: {
			duration: 0 // general animation time
		},
		responsiveAnimationDuration: 0, */ // animation duration after a resize
		maintainAspectRatio: false,
		animateScale : true,
		hover: { mode: "point" },
		legend: { display: false, position: "bottom", onClick: null },
		title: { display: true, text: txttitle },
		tooltips: {
			callbacks: {
					title: function (tooltipItem, data) { return (moment(tooltipItem[0].xLabel,"X").format('YYYY-MM-DD HH:mm:ss')); },
					label: function (tooltipItem, data) { return data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].y.toString() + ' ' + txtunity;}
				},
				mode: 'point',
				position: 'cursor',
				intersect: true
		},
		scales: {
			xAxes: [{
				type: "time",
				gridLines: { display: true, color: "#282828" },
				ticks: {
					min: moment().subtract(numunitx, txtunitx+"s"),
					display: true
				},
				time: { parser: "X", unit: txtunitx, stepSize: 1 }
			}],
			yAxes: [{
				gridLines: { display: false, color: "#282828" },
				scaleLabel: { display: false, labelString: txttitle },
				ticks: {
					display: true,
					callback: function (value, index, values) {
						return round(value,3).toFixed(3) + ' ' + txtunity;
					}
				},
			}]
		},
		plugins: {
			zoom: {
				pan: {
					enabled: false,
					mode: 'xy',
					rangeMin: {
						x: new Date().getTime() - (factor * numunitx),
						y: getLimit(txtchartname,"y","min",false) - Math.sqrt(Math.pow(getLimit(txtchartname,"y","min",false),2))*0.1,
					},
					rangeMax: {
						x: new Date().getTime(),
						y: getLimit(txtchartname,"y","max",false) + getLimit(txtchartname,"y","max",false)*0.1,
					},
				},
				zoom: {
					enabled: true,
					drag: true,
					mode: 'xy',
					rangeMin: {
						x: new Date().getTime() - (factor * numunitx),
						y: getLimit(txtchartname,"y","min",false) - Math.sqrt(Math.pow(getLimit(txtchartname,"y","min",false),2))*0.1,
					},
					rangeMax: {
						x: new Date().getTime(),
						y: getLimit(txtchartname,"y","max",false) + getLimit(txtchartname,"y","max",false)*0.1,
					},
					speed: 0.1
				},
			},
			datasource: {
				type: 'csv',
				url: '/ext/connmon/csv/'+txtchartname+'.htm',
				delimiter: ',',
				rowMapping: 'datapoint',
				datapointLabelMapping: {
					_dataset: 'Metric',
					x: 'Time',
					y: 'Value'
				}
			},
			deferred: {
				delay: 250
			},
		},
		annotation: {
			drawTime: 'afterDatasetsDraw',
			annotations: [{
				//id: 'avgline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'y-axis-0',
				value: getAverage(txtchartname),
				borderColor: colourname,
				borderWidth: 1,
				borderDash: [5, 5],
				label: {
					backgroundColor: 'rgba(0,0,0,0.3)',
					fontFamily: "sans-serif",
					fontSize: 10,
					fontStyle: "bold",
					fontColor: "#fff",
					xPadding: 6,
					yPadding: 6,
					cornerRadius: 6,
					position: "center",
					enabled: true,
					xAdjust: 0,
					yAdjust: 0,
					content: "Avg=" + round(getAverage(txtchartname),3).toFixed(3)+txtunity,
				}
			},
			{
				//id: 'maxline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'y-axis-0',
				value: getLimit(txtchartname,"y","max",true),
				borderColor: colourname,
				borderWidth: 1,
				borderDash: [5, 5],
				label: {
					backgroundColor: 'rgba(0,0,0,0.3)',
					fontFamily: "sans-serif",
					fontSize: 10,
					fontStyle: "bold",
					fontColor: "#fff",
					xPadding: 6,
					yPadding: 6,
					cornerRadius: 6,
					position: "center",
					enabled: true,
					xAdjust: 0,
					yAdjust: 0,
					content: "Max=" + round(getLimit(txtchartname,"y","max",true),3).toFixed(3)+txtunity,
				}
			},
			{
				//id: 'minline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'y-axis-0',
				value: getLimit(txtchartname,"y","min",true),
				borderColor: colourname,
				borderWidth: 1,
				borderDash: [5, 5],
				label: {
					backgroundColor: 'rgba(0,0,0,0.3)',
					fontFamily: "sans-serif",
					fontSize: 10,
					fontStyle: "bold",
					fontColor: "#fff",
					xPadding: 6,
					yPadding: 6,
					cornerRadius: 6,
					position: "center",
					enabled: true,
					xAdjust: 0,
					yAdjust: 0,
					content: "Min=" + round(getLimit(txtchartname,"y","min",true),3).toFixed(3)+txtunity,
				}
			}]
		}
	};
	var lineDataset = {
		datasets: [{label: txttitle,
			borderWidth: 1,
			pointRadius: 1,
			lineTension: 0,
			fill: ShowFill,
			backgroundColor: colourname,
			borderColor: colourname,
		}]
	};
	objchartname = new Chart(ctx, {
		type: 'line',
		plugins: [ChartDataSource,datafilterPlugin],
		options: lineOptions,
		data: lineDataset
	});
	window["LineChart"+txtchartname]=objchartname;
}

function getLimit(datasetname,axis,maxmin,isannotation) {
	var limit = 0;
	var objdataname=window[datasetname+maxmin];
	if(typeof objdataname === 'undefined' || objdataname === null) { limit = 0; }
	else {limit = objdataname;}
	if(maxmin == "max" && limit == 0 && isannotation == false){
		limit = 1;
	}
	return limit;
}

function getAverage(datasetname) {
	var avg = 0;
	var objdataname=window[datasetname+"avg"];
	if(typeof objdataname === 'undefined' || objdataname === null) { avg = 0; }
	else {avg = objdataname;}
	return avg;
}

function round(value, decimals) {
	return Number(Math.round(value+'e'+decimals)+'e-'+decimals);
}

function ToggleLines() {
	if(ShowLines == ""){
		ShowLines = "line";
		SetCookie("ShowLines","line");
	}
	else {
		ShowLines = "";
		SetCookie("ShowLines","");
	}
	for(i = 0; i < metriclist.length; i++){
		for (i2 = 0; i2 < chartlist.length; i2++) {
			for (i3 = 0; i3 < 3; i3++) {
				window["LineChart"+metriclist[i]+chartlist[i2]].options.annotation.annotations[i3].type=ShowLines;
			}
			window["LineChart"+metriclist[i]+chartlist[i2]].update();
		}
	}
}

function ToggleFill() {
	if(ShowFill == "false"){
		ShowFill = "origin";
		SetCookie("ShowFill","origin");
	}
	else {
		ShowFill = "false";
		SetCookie("ShowFill","false");
	}
	for(i = 0; i < metriclist.length; i++){
		for (i2 = 0; i2 < chartlist.length; i2++) {
			window["LineChart"+metriclist[i]+chartlist[i2]].data.datasets[0].fill=ShowFill;
			window["LineChart"+metriclist[i]+chartlist[i2]].update();
		}
	}
}

function RedrawAllCharts() {
	for(i = 0; i < metriclist.length; i++){
		for (i2 = 0; i2 < chartlist.length; i2++) {
			Draw_Chart(metriclist[i]+chartlist[i2],titlelist[i],measureunitlist[i],timeunitlist[i2],intervallist[i2],colourlist[i]);
		}
	}
	ResetZoom();
}

function GetCookie(cookiename) {
	var s;
	if ((s = cookie.get("conn_"+cookiename)) != null) {
		return cookie.get("conn_"+cookiename);
	}
	else {
		return "";
	}
}

function SetCookie(cookiename,cookievalue) {
	cookie.set("conn_"+cookiename, cookievalue, 31);
}

function AddEventHandlers(){
	$(".collapsible-jquery").click(function(){
		$(this).siblings().toggle("fast",function(){
			if($(this).css("display") == "none"){
				SetCookie($(this).siblings()[0].id,"collapsed");
			} else {
				SetCookie($(this).siblings()[0].id,"expanded");
			}
		})
	});
	
	if(GetCookie($(".collapsible-jquery")[0].id) == "collapsed"){
		$($(".collapsible-jquery")[0]).siblings().toggle(false);
	}
	
	var coll = document.getElementsByClassName("collapsible");
	var i;
	
	for (i = 0; i < coll.length; i++) {
		coll[i].addEventListener("click", function() {
			this.classList.toggle("active");
			var content = this.nextElementSibling.firstElementChild.firstElementChild.firstElementChild;
			if (content.style.maxHeight){
				content.style.maxHeight = null;
				SetCookie(this.id,"collapsed");
			} else {
				content.style.maxHeight = content.scrollHeight + "px";
				SetCookie(this.id,"expanded");
			}
		});
		if(GetCookie(coll[i].id) == "expanded"){
			coll[i].click();
		}
	}
}

function SetCurrentPage(){
	document.form.next_page.value = window.location.pathname.substring(1);
	document.form.current_page.value = window.location.pathname.substring(1);
}

function initial(){
	SetCurrentPage();
	LoadCustomSettings();
	show_menu();
	RedrawAllCharts();
	SetConnmonStatsTitle();
	AddEventHandlers();
}

function reload() {
	location.reload(true);
}

function ResetZoom(){
	for(i = 0; i < metriclist.length; i++){
		for (i2 = 0; i2 < chartlist.length; i2++) {
			var chartobj = window["LineChart"+metriclist[i]+chartlist[i2]];
			if(typeof chartobj === 'undefined' || chartobj === null) { continue; }
			chartobj.resetZoom();
		}
	}
}

function DragZoom(button){
	var drag = true;
	var pan = false;
	var buttonvalue = "";
	if(button.value.indexOf("Disable") != -1){
		drag = false;
		pan = true;
		buttonvalue = "Enable Drag Zoom";
	}
	else {
		drag = true;
		pan = false;
		buttonvalue = "Disable Drag Zoom";
	}
	
	for(i = 0; i < metriclist.length; i++){
		for (i2 = 0; i2 < chartlist.length; i2++) {
			var chartobj = window["LineChart"+metriclist[i]+chartlist[i2]];
			if(typeof chartobj === 'undefined' || chartobj === null) { continue; }
			chartobj.options.plugins.zoom.zoom.drag = drag;
			chartobj.options.plugins.zoom.pan.enabled = pan;
			button.value = buttonvalue;
			chartobj.update();
		}
	}
}

function applyRule() {
	if(Validate_All()){
		document.getElementById('amng_custom').value = JSON.stringify($('form').serializeObject())
		var action_script_tmp = "start_connmonconfig";
		document.form.action_script.value = action_script_tmp;
		var restart_time = document.form.action_wait.value*1;
		showLoading();
		document.form.submit();
	}
	else{
		return false;
	}
}

function runPingTest() {
	var action_script_tmp = "start_connmon";
	document.form.action_script.value = action_script_tmp;
	var restart_time = document.form.action_wait.value*1;
	showLoading();
	document.form.submit();
}

</script>
</head>
<body onload="initial();" onunload="return unload_body();">
<div id="TopBanner"></div>
<div id="Loading" class="popup_bg"></div>
<iframe name="hidden_frame" id="hidden_frame" src="about:blank" width="0" height="0" frameborder="0"></iframe>
<form method="post" name="form" id="ruleForm" action="/start_apply.htm" target="hidden_frame">
<input type="hidden" name="current_page" value="">
<input type="hidden" name="next_page" value="">
<input type="hidden" name="modified" value="0">
<input type="hidden" name="action_mode" value="apply">
<input type="hidden" name="action_script" value="start_connmon">
<input type="hidden" name="action_wait" value="60">
<input type="hidden" name="first_time" value="">
<input type="hidden" name="SystemCmd" value="">
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>">
<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>">
<input type="hidden" name="amng_custom" id="amng_custom" value="">
<table class="content" align="center" cellpadding="0" cellspacing="0">
<tr>
<td width="17">&nbsp;</td>
<td valign="top" width="202">
<div id="mainMenu"></div>
<div id="subMenu"></div></td>
<td valign="top">
<div id="tabMenu" class="submenuBlock"></div>
<table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
<tr>
<td valign="top">
<table width="760px" border="0" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTitle" id="FormTitle">
<tbody>
<tr bgcolor="#4D595D">
<td valign="top">
<div>&nbsp;</div>
<div class="formfonttitle" id="statstitle">Internet Uptime Monitoring</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:0px;">
<tr class="apply_gen" valign="top" height="35px">
<td style="background-color:rgb(77, 89, 93);border:0px;">
<input type="button" onclick="runPingTest();" value="Update stats" class="button_gen" name="button">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" onclick="DragZoom(this);" value="Disable Drag Zoom" class="button_gen" name="button">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" onclick="ResetZoom();" value="Reset Zoom" class="button_gen" name="button">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" onclick="ToggleLines();" value="Toggle Lines" class="button_gen" name="button">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" onclick="ToggleFill();" value="Toggle Fill" class="button_gen" name="button">
</td>
</tr>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="TableConfig">
<thead class="collapsible-jquery" id="thconfig">
<tr>
<td colspan="2">Configuration (click to expand/collapse)</td>
</tr>
</thead>
<div class="collapsiblecontent">
<tr class="even">
<th width="40%">Ping destination type</th>
<td>
<select style="width:100px" class="input_option" onchange="changePingType(this)" id="pingtype">
<option value="0">IP Address</option>
<option value="1">Domain</option>
</select>
</td>
</tr>
<tr class="even" id="rowip">
<th width="40%">IP Address</th>
<td>
<input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_20_table" name="connmon_ipaddr" value="8.8.8.8" onkeypress="return validator.isIPAddr(this, event)" onblur="Validate_IP(this)" data-lpignore="true" />
</td>
</tr>
<tr class="even" id="rowdomain">
<th width="40%">Domain</th>
<td>
<input autocorrect="off" autocapitalize="off" type="text" maxlength="255" class="input_32_table" name="connmon_domain" value="google.co.uk" onkeypress="return validator.isString(this, event);" onblur="Validate_Domain(this)" data-lpignore="true" />
</td>
</tr>
<tr class="apply_gen" valign="top" height="35px">
<td colspan="2" style="background-color:rgb(77, 89, 93);border:0px;">
<input type="button" onclick="applyRule();" value="Save" class="button_gen" name="button">
</td>
</tr>
</div>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
<thead class="collapsible" id="last24">
<tr>
<td colspan="2">Last 24 Hours (click to expand/collapse)</td>
</tr>
</thead>
<tr>
<td colspan="2" align="center" style="padding: 0px;">
<div class="collapsiblecontent">
<div style="background-color:#2f3e44;border-radius:10px;width:730px;padding-left:5px;"><canvas id="divLineChartPingdaily" height="300" /></div>
<div style="line-height:10px;">&nbsp;</div>
<div style="background-color:#2f3e44;border-radius:10px;width:730px;padding-left:5px;"><canvas id="divLineChartJitterdaily" height="300" /></div>
<div style="line-height:10px;">&nbsp;</div>
<div style="background-color:#2f3e44;border-radius:10px;width:730px;padding-left:5px;"><canvas id="divLineChartPacket_Lossdaily" height="300" /></div>
</div>
</td>
</tr>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
<thead class="collapsible" id="last7">
<tr>
<td colspan="2">Last 7 days (click to expand/collapse)</td>
</tr>
</thead>
<tr>
<td colspan="2" align="center" style="padding: 0px;">
<div class="collapsiblecontent">
<div style="background-color:#2f3e44;border-radius:10px;width:730px;padding-left:5px;"><canvas id="divLineChartPingweekly" height="300" /></div>
<div style="line-height:10px;">&nbsp;</div>
<div style="background-color:#2f3e44;border-radius:10px;width:730px;padding-left:5px;"><canvas id="divLineChartJitterweekly" height="300" /></div>
<div style="line-height:10px;">&nbsp;</div>
<div style="background-color:#2f3e44;border-radius:10px;width:730px;padding-left:5px;"><canvas id="divLineChartPacket_Lossweekly" height="300" /></div>
</div>
</td>
</tr>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
<thead class="collapsible" id="last30">
<tr>
<td colspan="2">Last 30 days (click to expand/collapse)</td>
</tr>
</thead>
<tr>
<td colspan="2" align="center" style="padding: 0px;">
<div class="collapsiblecontent">
<div style="background-color:#2f3e44;border-radius:10px;width:730px;padding-left:5px;"><canvas id="divLineChartPingmonthly" height="300" /></div>
<div style="line-height:10px;">&nbsp;</div>
<div style="background-color:#2f3e44;border-radius:10px;width:730px;padding-left:5px;"><canvas id="divLineChartJittermonthly" height="300" /></div>
<div style="line-height:10px;">&nbsp;</div>
<div style="background-color:#2f3e44;border-radius:10px;width:730px;padding-left:5px;"><canvas id="divLineChartPacket_Lossmonthly" height="300" /></div>
</div>
</td>
</tr>
</table>
</td>
</tr>
</tbody>
</table>
</td>
</tr>
</table>
</td>
</tr>
</table>
</form>
<div id="footer">
</div>
</body>
</html>
