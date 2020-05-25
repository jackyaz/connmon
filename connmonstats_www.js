var custom_settings;

function LoadCustomSettings(){
	custom_settings = <% get_custom_settings(); %>;
	for (var prop in custom_settings) {
		if (Object.prototype.hasOwnProperty.call(custom_settings, prop)) {
			if(prop.indexOf("connmon") != -1 && prop.indexOf("connmon_version") == -1){
				eval("delete custom_settings."+prop)
			}
		}
	}
}

var $j = jQuery.noConflict(); //avoid conflicts on John's fork (state.js)

var maxNoCharts = 9;
var currentNoCharts = 0;
var ShowLines = GetCookie("ShowLines","string");
var ShowFill = GetCookie("ShowFill","string");
if( ShowFill == "" ){
	ShowFill = "origin";
}
var DragZoom = true;
var ChartPan = false;

Chart.defaults.global.defaultFontColor = "#CCC";
Chart.Tooltip.positioners.cursor = function(chartElements, coordinates) {
	return coordinates;
};

var metriclist = ["Ping","Jitter","PacketLoss"];
var titlelist = ["Ping","Jitter","Quality"];
var measureunitlist = ["ms","ms","%"];
var chartlist = ["daily","weekly","monthly"];
var timeunitlist = ["hour","day","day"];
var intervallist = [24,7,30];
var bordercolourlist = ["#fc8500","#42ecf5","#ffffff"];
var backgroundcolourlist = ["rgba(252,133,0,0.5)","rgba(66,236,245,0.5)","rgba(255,255,255,0.5)"];

function keyHandler(e) {
	if (e.keyCode == 27){
		$j(document).off("keydown");
		ResetZoom();
	}
}

$j(document).keydown(function(e){keyHandler(e);});
$j(document).keyup(function(e){
	$j(document).keydown(function(e){
		keyHandler(e);
	});
});

function Validate_IP(forminput){
	var inputvalue = forminput.value;
	var inputname = forminput.name;
	if(/^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test(inputvalue)){
			$j(forminput).removeClass("invalid");
			return true;
	}
	else{
		$j(forminput).addClass("invalid");
		return false;
	}
}

function Validate_Domain(forminput){
	var inputvalue = forminput.value;
	var inputname = forminput.name;
	if(/^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$/.test(inputvalue)){
		$j(forminput).removeClass("invalid");
		return true;
	}
	else{
		$j(forminput).addClass("invalid");
		return false;
	}
}

function Validate_All(){
	var validationfailed = false;
	if(! Validate_IP(document.form.connmon_ipaddr)){validationfailed=true;}
	if(! Validate_Domain(document.form.connmon_domain)){validationfailed=true;}
	
	if(validationfailed){
		alert("Validation for some fields failed. Please correct invalid values and try again.");
		return false;
	}
	else{
		return true;
	}
}

function changePingType(forminput){
	var inputvalue = forminput.value;
	var inputname = forminput.name;
	if(inputvalue == "0"){
		document.getElementById("rowip").style.display = "";
		document.getElementById("rowdomain").style.display = "none";
	} else {
		document.getElementById("rowip").style.display = "none";
		document.getElementById("rowdomain").style.display = "";
	}
}

function Draw_Chart_NoData(txtchartname){
	document.getElementById("divLineChart_"+txtchartname).width="730";
	document.getElementById("divLineChart_"+txtchartname).height="500";
	document.getElementById("divLineChart_"+txtchartname).style.width="730px";
	document.getElementById("divLineChart_"+txtchartname).style.height="500px";
	var ctx = document.getElementById("divLineChart_"+txtchartname).getContext("2d");
	ctx.save();
	ctx.textAlign = 'center';
	ctx.textBaseline = 'middle';
	ctx.font = "normal normal bolder 48px Arial";
	ctx.fillStyle = 'white';
	ctx.fillText('No data to display', 365, 250);
	ctx.restore();
}

function Draw_Chart(txtchartname,txttitle,txtunity,bordercolourname,backgroundcolourname){
	txtchartname
	var chartperiod = getChartPeriod($j("#" + txtchartname + "_Period option:selected").val());
	var txtunitx = timeunitlist[$j("#" + txtchartname + "_Period option:selected").val()];
	var numunitx = intervallist[$j("#" + txtchartname + "_Period option:selected").val()];
	var dataobject = window[txtchartname+chartperiod];
	
	if(typeof dataobject === 'undefined' || dataobject === null) { Draw_Chart_NoData(txtchartname); return; }
	if (dataobject.length == 0) { Draw_Chart_NoData(txtchartname); return; }
	
	var chartLabels = dataobject.map(function(d) {return d.Metric});
	var chartData = dataobject.map(function(d) {return {x: d.Time, y: d.Value}});
	var objchartname=window["LineChart_"+txtchartname];
	
	var timeaxisformat = getTimeFormat($j("#Time_Format option:selected").val(),"axis");
	var timetooltipformat = getTimeFormat($j("#Time_Format option:selected").val(),"tooltip");
	
	factor=0;
	if (txtunitx=="hour"){
		factor=60*60*1000;
	}
	else if (txtunitx=="day"){
		factor=60*60*24*1000;
	}
	if (objchartname != undefined) objchartname.destroy();
	var ctx = document.getElementById("divLineChart_"+txtchartname).getContext("2d");
	var lineOptions = {
		segmentShowStroke : false,
		segmentStrokeColor : "#000",
		animationEasing : "easeOutQuart",
		animationSteps : 100,
		maintainAspectRatio: false,
		animateScale : true,
		hover: { mode: "point" },
		legend: { display: false, position: "bottom", onClick: null },
		title: { display: true, text: txttitle },
		tooltips: {
			callbacks: {
				title: function (tooltipItem, data) { return (moment(tooltipItem[0].xLabel,"X").format(timetooltipformat)); },
				label: function (tooltipItem, data) { return round(data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].y,3).toFixed(3) + ' ' + txtunity;}
			},
			mode: 'x',
			position: 'nearest',
			intersect: false
		},
		scales: {
			xAxes: [{
				type: "time",
				gridLines: { display: true, color: "#282828" },
				ticks: {
					min: moment().subtract(numunitx, txtunitx+"s"),
					display: true
				},
				time: {
					parser: "X",
					unit: txtunitx,
					stepSize: 1,
					displayFormats: timeaxisformat
				}
			}],
			yAxes: [{
				gridLines: { display: false, color: "#282828" },
				scaleLabel: { display: false, labelString: txttitle },
				ticks: {
					display: true,
					beginAtZero: true,
					callback: function (value, index, values) {
						return round(value,3).toFixed(3) + ' ' + txtunity;
					}
				},
			}]
		},
		plugins: {
			zoom: {
				pan: {
					enabled: ChartPan,
					mode: 'xy',
					rangeMin: {
						x: new Date().getTime() - (factor * numunitx),
						y: 0,
					},
					rangeMax: {
						x: new Date().getTime(),
						y: getLimit(chartData,"y","max",false) + getLimit(chartData,"y","max",false)*0.1,
					},
				},
				zoom: {
					enabled: true,
					drag: DragZoom,
					mode: 'xy',
					rangeMin: {
						x: new Date().getTime() - (factor * numunitx),
						y: 0,
					},
					rangeMax: {
						x: new Date().getTime(),
						y: getLimit(chartData,"y","max",false) + getLimit(chartData,"y","max",false)*0.1,
					},
					speed: 0.1
				},
			},
		},
		annotation: {
			drawTime: 'afterDatasetsDraw',
			annotations: [{
				//id: 'avgline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'y-axis-0',
				value: getAverage(chartData),
				borderColor: bordercolourname,
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
					content: "Avg=" + round(getAverage(chartData),3).toFixed(3)+txtunity,
				}
			},
			{
				//id: 'maxline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'y-axis-0',
				value: getLimit(chartData,"y","max",true),
				borderColor: bordercolourname,
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
					position: "right",
					enabled: true,
					xAdjust: 15,
					yAdjust: 0,
					content: "Max=" + round(getLimit(chartData,"y","max",true),3).toFixed(3)+txtunity,
				}
			},
			{
				//id: 'minline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'y-axis-0',
				value: getLimit(chartData,"y","min",true),
				borderColor: bordercolourname,
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
					position: "left",
					enabled: true,
					xAdjust: 15,
					yAdjust: 0,
					content: "Min=" + round(getLimit(chartData,"y","min",true),3).toFixed(3)+txtunity,
				}
			}]
		}
	};
	var lineDataset = {
		labels: chartLabels,
		datasets: [{data: chartData,
			borderWidth: 1,
			pointRadius: 1,
			lineTension: 0,
			fill: ShowFill,
			backgroundColor: backgroundcolourname,
			borderColor: bordercolourname,
		}]
	};
	objchartname = new Chart(ctx, {
		type: 'line',
		options: lineOptions,
		data: lineDataset
	});
	window["LineChart_"+txtchartname]=objchartname;
}

function getLimit(datasetname,axis,maxmin,isannotation) {
	var limit=0;
	var values;
	if(axis == "x"){
		values = datasetname.map(function(o) { return o.x } );
	}
	else{
		values = datasetname.map(function(o) { return o.y } );
	}
	
	if(maxmin == "max"){
		limit=Math.max.apply(Math, values);
	}
	else{
		limit=Math.min.apply(Math, values);
	}
	if(maxmin == "max" && limit == 0 && isannotation == false){
		limit = 1;
	}
	return limit;
}

function getAverage(datasetname) {
	var total = 0;
	for(var i = 0; i < datasetname.length; i++) {
		total += (datasetname[i].y*1);
	}
	var avg = total / datasetname.length;
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
		for (i3 = 0; i3 < 3; i3++) {
			window["LineChart_"+metriclist[i]].options.annotation.annotations[i3].type=ShowLines;
		}
		window["LineChart_"+metriclist[i]].update();
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
		window["LineChart_"+metriclist[i]].data.datasets[0].fill=ShowFill;
		window["LineChart_"+metriclist[i]].update();
	}
}

function RedrawAllCharts() {
	for(i = 0; i < metriclist.length; i++){
		for (i2 = 0; i2 < chartlist.length; i2++) {
			d3.csv('/ext/connmon/csv/'+metriclist[i].replace("PacketLoss","Packet_Loss")+chartlist[i2]+'.htm').then(SetGlobalDataset.bind(null,metriclist[i]+chartlist[i2]));
		}
	}
}

function SetGlobalDataset(txtchartname,dataobject){
	window[txtchartname] = dataobject;
	currentNoCharts++;
	if(currentNoCharts == maxNoCharts) {
		for(i = 0; i < metriclist.length; i++){
			$j("#"+metriclist[i]+"_Period").val(GetCookie(metriclist[i]+"_Period","number"));
			Draw_Chart(metriclist[i],titlelist[i],measureunitlist[i],bordercolourlist[i],backgroundcolourlist[i]);
		}
	}
}

function getTimeFormat(value,format) {
	var timeformat;
	
	if(format == "axis"){
		if (value == 0){
			timeformat = {
				millisecond: 'HH:mm:ss.SSS',
				second: 'HH:mm:ss',
				minute: 'HH:mm',
				hour: 'HH:mm'
			}
		}
		else if (value == 1){
			timeformat = {
				millisecond: 'h:mm:ss.SSS A',
				second: 'h:mm:ss A',
				minute: 'h:mm A',
				hour: 'h A'
			}
		}
	}
	else if(format == "tooltip"){
		if (value == 0){
			timeformat = "YYYY-MM-DD HH:mm:ss";
		}
		else if (value == 1){
			timeformat = "YYYY-MM-DD h:mm:ss A";
		}
	}
	
	return timeformat;
}

function GetCookie(cookiename,returntype) {
	var s;
	if ((s = cookie.get("conn_"+cookiename)) != null) {
		return cookie.get("conn_"+cookiename);
	}
	else {
		if(returntype == "string"){
			return "";
		}
		else if(returntype == "number"){
			return 0;
		}
	}
}

function SetCookie(cookiename,cookievalue) {
	cookie.set("conn_"+cookiename, cookievalue, 31);
}

function AddEventHandlers(){
	$j(".collapsible-jquery").click(function(){
		$j(this).siblings().toggle("fast",function(){
			if($j(this).css("display") == "none"){
				SetCookie($j(this).siblings()[0].id,"collapsed");
			}
			else {
				SetCookie($j(this).siblings()[0].id,"expanded");
			}
		})
	});

	$j(".collapsible-jquery").each(function(index,element){
		if(GetCookie($j(this)[0].id,"string") == "collapsed"){
			$j(this).siblings().toggle(false);
		}
		else {
			$j(this).siblings().toggle(true);
		}
	});
}

$j.fn.serializeObject = function(){
	var o = custom_settings;
	var a = this.serializeArray();
	$j.each(a, function() {
		if (o[this.name] !== undefined && this.name.indexOf("connmon_pingserver") != -1) {
			if (!o[this.name].push) {
				o[this.name] = [o[this.name]];
			}
			o[this.name].push(this.value || '');
		} else if (this.name.indexOf("connmon_pingserver") != -1){
			o[this.name] = this.value || '';
		}
	});
	return o;
};

function SetCurrentPage(){
	document.form.next_page.value = window.location.pathname.substring(1);
	document.form.current_page.value = window.location.pathname.substring(1);
}

function initial(){
	SetCurrentPage();
	LoadCustomSettings();
	show_menu();
	get_conf_file();
	$j("#Time_Format").val(GetCookie("Time_Format","number"));
	RedrawAllCharts();
	ScriptUpdateLayout();
	SetConnmonStatsTitle();
	AddEventHandlers();
}

function ScriptUpdateLayout(){
	var localver = GetVersionNumber("local");
	var serverver = GetVersionNumber("server");
	$j("#scripttitle").text($j("#scripttitle").text()+" - "+localver);
	$j("#connmon_version_local").text(localver);
	
	if (localver != serverver && serverver != "N/A"){
		$j("#connmon_version_server").text("Updated version available: "+serverver);
		showhide("btnChkUpdate", false);
		showhide("connmon_version_server", true);
		showhide("btnDoUpdate", true);
	}
}

function reload() {
	location.reload(true);
}

function getChartPeriod(period) {
	var chartperiod = "daily";
	if (period == 0) chartperiod = "daily";
	else if (period == 1) chartperiod = "weekly";
	else if (period == 2) chartperiod = "monthly";
	return chartperiod;
}

function ResetZoom(){
	for(i = 0; i < metriclist.length; i++){
		var chartobj = window["LineChart_"+metriclist[i]];
		if(typeof chartobj === 'undefined' || chartobj === null) { continue; }
		chartobj.resetZoom();
	}
}

function ToggleDragZoom(button){
	var drag = true;
	var pan = false;
	var buttonvalue = "";
	if(button.value.indexOf("On") != -1){
		drag = false;
		pan = true;
		DragZoom = false;
		ChartPan = true;
		buttonvalue = "Drag Zoom Off";
	}
	else {
		drag = true;
		pan = false;
		DragZoom = true;
		ChartPan = false;
		buttonvalue = "Drag Zoom On";
	}
	
	for(i = 0; i < metriclist.length; i++){
		var chartobj = window["LineChart_"+metriclist[i]];
		if(typeof chartobj === 'undefined' || chartobj === null) { continue; }
		chartobj.options.plugins.zoom.zoom.drag = drag;
		chartobj.options.plugins.zoom.pan.enabled = pan;
		button.value = buttonvalue;
		chartobj.update();
}
}

function ExportCSV() {
	location.href = "ext/connmon/csv/connmondata.zip";
	return 0;
}

function CheckUpdate(){
	var action_script_tmp = "start_connmoncheckupdate";
	document.form.action_script.value = action_script_tmp;
	var restart_time = 10;
	document.form.action_wait.value = restart_time;
	showLoading();
	document.form.submit();
}

function DoUpdate(){
	var action_script_tmp = "start_connmondoupdate";
	document.form.action_script.value = action_script_tmp;
	var restart_time = 20;
	document.form.action_wait.value = restart_time;
	showLoading();
	document.form.submit();
}

function applyRule() {
	if(Validate_All()){
		if(document.form.pingtype.value == 0){
			document.form.connmon_pingserver.value = document.form.connmon_ipaddr.value;
		} else if(document.form.pingtype.value == 1) {
			document.form.connmon_pingserver.value = document.form.connmon_domain.value;
		}
		document.getElementById('amng_custom').value = JSON.stringify($j('form').serializeObject())
		var action_script_tmp = "start_connmonconfig";
		document.form.action_script.value = action_script_tmp;
		var restart_time = 5;
		document.form.action_wait.value = restart_time;
		showLoading();
		document.form.submit();
	}
	else {
		return false;
	}
}

function GetVersionNumber(versiontype)
{
	var versionprop;
	if(versiontype == "local"){
		versionprop = custom_settings.connmon_version_local;
	}
	else if(versiontype == "server"){
		versionprop = custom_settings.connmon_version_server;
	}
	
	if(typeof versionprop == 'undefined' || versionprop == null){
		return "N/A";
	}
	else {
		return versionprop;
	}
}

function get_conf_file(){
	$j.ajax({
		url: '/ext/connmon/config.htm',
		dataType: 'text',
		error: function(xhr){
			setTimeout("get_conf_file();", 1000);
		},
		success: function(data){
			var pingserver=data.split("\n")[0].split("=")[1].replace(/(\r\n|\n|\r)/gm,"");
			document.form.connmon_pingserver.value = pingserver;
			if(Validate_IP(document.form.connmon_pingserver)) {
				document.form.pingtype.value=0;
				document.form.connmon_ipaddr.value=pingserver;
			} else {
				document.form.pingtype.value=1;
				document.form.connmon_domain.value=pingserver;
			}
			document.form.pingtype.onchange();
		}
	});
}

function runPingTest() {
	var action_script_tmp = "start_connmon";
	document.form.action_script.value = action_script_tmp;
	var restart_time = 45;
	document.form.action_wait.value = restart_time;
	showLoading();
	document.form.submit();
}

function changeAllCharts(e) {
	value = e.value * 1;
	name = e.id.substring(0, e.id.indexOf("_"));
	SetCookie(e.id,value);
	for (i = 0; i < metriclist.length; i++) {
		Draw_Chart(metriclist[i],titlelist[i],measureunitlist[i],bordercolourlist[i],backgroundcolourlist[i]);
	}
}

function changeChart(e) {
	value = e.value * 1;
	name = e.id.substring(0, e.id.indexOf("_"));
	SetCookie(e.id,value);
	
	if(name == "Ping"){
		Draw_Chart("Ping",titlelist[0],measureunitlist[0],bordercolourlist[0],backgroundcolourlist[0]);
	}
	else if(name == "Jitter"){
		Draw_Chart("Jitter",titlelist[1],measureunitlist[1],bordercolourlist[1],backgroundcolourlist[1]);
	}
	else if(name == "PacketLoss"){
		Draw_Chart("PacketLoss",titlelist[2],measureunitlist[2],bordercolourlist[2],backgroundcolourlist[2]);
	}
}
