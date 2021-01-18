var $j = jQuery.noConflict(); //avoid conflicts on John's fork (state.js)

var pingtestdur=60;
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
Chart.Tooltip.positioners.cursor = function(chartElements, coordinates){
	return coordinates;
};

var metriclist = ["Ping","Jitter","LineQuality"];
var titlelist = ["Ping","Jitter","Quality"];
var measureunitlist = ["ms","ms","%"];
var chartlist = ["daily","weekly","monthly"];
var timeunitlist = ["hour","day","day"];
var intervallist = [24,7,30];
var bordercolourlist = ["#fc8500","#42ecf5","#ffffff"];
var backgroundcolourlist = ["rgba(252,133,0,0.5)","rgba(66,236,245,0.5)","rgba(255,255,255,0.5)"];

function keyHandler(e){
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

function Validate_PingDuration(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value*1;
	
	if(inputvalue > 60 || inputvalue < 10){
		$j(forminput).addClass("invalid");
		return false;
	}
	else{
		$j(forminput).removeClass("invalid");
		return true;
	}
}

function Validate_PingFrequency(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value*1;
	
	if(inputvalue > 10 || inputvalue < 1){
		$j(forminput).addClass("invalid");
		return false;
	}
	else{
		$j(forminput).removeClass("invalid");
		return true;
	}
}

function Validate_ScheduleRange(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value*1;
	
	if(inputvalue > 23 || inputvalue < 0 || forminput.value.length < 1){
		$j(forminput).addClass("invalid");
		return false;
	}
	else{
		$j(forminput).removeClass("invalid");
		return true;
	}
}

function Validate_All(){
	var validationfailed = false;
	if(! Validate_IP(document.form.connmon_ipaddr)){validationfailed=true;}
	if(! Validate_Domain(document.form.connmon_domain)){validationfailed=true;}
	if(! Validate_PingDuration(document.form.connmon_pingduration)){validationfailed=true;}
	if(! Validate_PingFrequency(document.form.connmon_pingfrequency)){validationfailed=true;}
	if(! Validate_ScheduleRange(document.form.connmon_schedulestart)) validationfailed=true;
	if(! Validate_ScheduleRange(document.form.connmon_scheduleend)) validationfailed=true;
	
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
	}
	else{
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
	var chartperiod = getChartPeriod($j("#" + txtchartname + "_Period option:selected").val());
	var txtunitx = timeunitlist[$j("#" + txtchartname + "_Period option:selected").val()];
	var numunitx = intervallist[$j("#" + txtchartname + "_Period option:selected").val()];
	var dataobject = window[txtchartname+chartperiod];
	
	if(typeof dataobject === 'undefined' || dataobject === null){ Draw_Chart_NoData(txtchartname); return; }
	if (dataobject.length == 0){ Draw_Chart_NoData(txtchartname); return; }
	
	var chartLabels = dataobject.map(function(d){return d.Metric});
	var chartData = dataobject.map(function(d){return {x: d.Time, y: d.Value}});
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
				title: function (tooltipItem, data){ return (moment(tooltipItem[0].xLabel,"X").format(timetooltipformat)); },
				label: function (tooltipItem, data){ return round(data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].y,2).toFixed(2) + ' ' + txtunity;}
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
				time: {
					parser: "X",
					unit: txtunitx,
					stepSize: 1,
					displayFormats: timeaxisformat
				}
			}],
			yAxes: [{
				type: getChartScale($j("#" + txtchartname + "_Scale option:selected").val()),
				gridLines: { display: false, color: "#282828" },
				scaleLabel: { display: false, labelString: txttitle },
				ticks: {
					display: true,
					beginAtZero: true,
					max: getYAxisMax(txtchartname),
					labels: {
						index:  ['min', 'max'],
						removeEmptyLines: true,
					},
					callback: function (value, index, values){
						return LogarithmicFormatter(value, index, values) + ' ' + txtunity;
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
					content: "Avg=" + round(getAverage(chartData),2).toFixed(2)+txtunity,
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
					content: "Max=" + round(getLimit(chartData,"y","max",true),2).toFixed(2)+txtunity,
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
					content: "Min=" + round(getLimit(chartData,"y","min",true),2).toFixed(2)+txtunity,
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

function LogarithmicFormatter(tickValue, index, ticks){
	if(this.type != "logarithmic"){
		if(! isNaN(tickValue)){
			return round(tickValue,2).toFixed(2);
		}
		else{
			return tickValue;
		}
	}
	else{
		var labelOpts =  this.options.ticks.labels || {};
		var labelIndex = labelOpts.index || ['min', 'max'];
		var labelSignificand = labelOpts.significand || [1,2,5];
		var significand = tickValue / (Math.pow(10, Math.floor(Chart.helpers.log10(tickValue))));
		var emptyTick = labelOpts.removeEmptyLines === true ? undefined : '';
		var namedIndex = '';
		if(index === 0){
			namedIndex = 'min';
		}
		else if(index === ticks.length - 1){
			namedIndex = 'max';
		}
		if(labelOpts === 'all' || labelSignificand.indexOf(significand) !== -1 || labelIndex.indexOf(index) !== -1 || labelIndex.indexOf(namedIndex) !== -1){
			if(tickValue === 0){
				return '0';
			}
			else{
				if(! isNaN(tickValue)){
					return round(tickValue,2).toFixed(2);
				}
				else{
					return tickValue;
				}
			}
		}
		return emptyTick;
	}
};

function getLimit(datasetname,axis,maxmin,isannotation){
	var limit=0;
	var values;
	if(axis == "x"){
		values = datasetname.map(function(o){ return o.x } );
	}
	else{
		values = datasetname.map(function(o){ return o.y } );
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

function getYAxisMax(chartname){
	if(chartname == "LineQuality"){
		return 100;
	}
}

function getAverage(datasetname){
	var total = 0;
	for(var i = 0; i < datasetname.length; i++){
		total += (datasetname[i].y*1);
	}
	var avg = total / datasetname.length;
	return avg;
}

function round(value, decimals){
	return Number(Math.round(value+'e'+decimals)+'e-'+decimals);
}

function ToggleLines(){
	if(ShowLines == ""){
		ShowLines = "line";
		SetCookie("ShowLines","line");
	}
	else{
		ShowLines = "";
		SetCookie("ShowLines","");
	}
	for(i = 0; i < metriclist.length; i++){
		for (i3 = 0; i3 < 3; i3++){
			window["LineChart_"+metriclist[i]].options.annotation.annotations[i3].type=ShowLines;
		}
		window["LineChart_"+metriclist[i]].update();
	}
}

function ToggleFill(){
	if(ShowFill == "false"){
		ShowFill = "origin";
		SetCookie("ShowFill","origin");
	}
	else{
		ShowFill = "false";
		SetCookie("ShowFill","false");
	}
	for(i = 0; i < metriclist.length; i++){
		window["LineChart_"+metriclist[i]].data.datasets[0].fill=ShowFill;
		window["LineChart_"+metriclist[i]].update();
	}
}

function RedrawAllCharts(){
	for(i = 0; i < metriclist.length; i++){
		for (i2 = 0; i2 < chartlist.length; i2++){
			d3.csv('/ext/connmon/csv/'+metriclist[i]+chartlist[i2]+'.htm').then(SetGlobalDataset.bind(null,metriclist[i]+chartlist[i2]));
		}
	}
}

function SetGlobalDataset(txtchartname,dataobject){
	window[txtchartname] = dataobject;
	currentNoCharts++;
	if(currentNoCharts == maxNoCharts){
		showhide("imgConnTest", false);
		showhide("conntest_text", false);
		showhide("btnRunPingtest", true);
		BuildLastXTable();
		for(i = 0; i < metriclist.length; i++){
			$j("#"+metriclist[i]+"_Period").val(GetCookie(metriclist[i]+"_Period","number"));
			$j("#"+metriclist[i]+"_Scale").val(GetCookie(metriclist[i]+"_Scale","number"));
			Draw_Chart(metriclist[i],titlelist[i],measureunitlist[i],bordercolourlist[i],backgroundcolourlist[i]);
		}
		AddEventHandlers();
	}
}

function getChartScale(scale){
	var chartscale = "";
	if(scale == 0){
		chartscale = "linear";
	}
	else if(scale == 1){
		chartscale = "logarithmic";
	}
	return chartscale;
}

function getTimeFormat(value,format){
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

function GetCookie(cookiename,returntype){
	var s;
	if ((s = cookie.get("conn_"+cookiename)) != null){
		return cookie.get("conn_"+cookiename);
	}
	else{
		if(returntype == "string"){
			return "";
		}
		else if(returntype == "number"){
			return 0;
		}
	}
}

function SetCookie(cookiename,cookievalue){
	cookie.set("conn_"+cookiename, cookievalue, 31);
}

function AddEventHandlers(){
	$j(".collapsible-jquery").click(function(){
		$j(this).siblings().toggle("fast",function(){
			if($j(this).css("display") == "none"){
				SetCookie($j(this).siblings()[0].id,"collapsed");
			}
			else{
				SetCookie($j(this).siblings()[0].id,"expanded");
			}
		})
	});

	$j(".collapsible-jquery").each(function(index,element){
		if(GetCookie($j(this)[0].id,"string") == "collapsed"){
			$j(this).siblings().toggle(false);
		}
		else{
			$j(this).siblings().toggle(true);
		}
	});
}

$j.fn.serializeObject = function(){
	var o = custom_settings;
	var a = this.serializeArray();
	$j.each(a, function(){
		if (o[this.name] !== undefined && this.name.indexOf("connmon") != -1 && this.name.indexOf("version") == -1 && this.name.indexOf("ipaddr") == -1 && this.name.indexOf("domain") == -1){
			if (!o[this.name].push){
				o[this.name] = [o[this.name]];
			}
			o[this.name].push(this.value || '');
		} else if (this.name.indexOf("connmon") != -1 && this.name.indexOf("version") == -1 && this.name.indexOf("ipaddr") == -1 && this.name.indexOf("domain") == -1){
			o[this.name] = this.value || '';
		}
	});
	return o;
};

function SetCurrentPage(){
	document.form.next_page.value = window.location.pathname.substring(1);
	document.form.current_page.value = window.location.pathname.substring(1);
}

function ParseCSVExport(data){
	var csvContent = "Timestamp,Ping,Jitter,LineQuality\n";
	for(var i = 0; i < data.length; i++){
		var dataString = data[i].Timestamp+","+data[i].Ping+","+data[i].Jitter+","+data[i].LineQuality;
		csvContent += i < data.length-1 ? dataString + '\n' : dataString;
	}
	document.getElementById("aExport").href="data:text/csv;charset=utf-8," + encodeURIComponent(csvContent);
}

function initial(){
	SetCurrentPage();
	LoadCustomSettings();
	show_menu();
	get_conf_file();
	d3.csv('/ext/connmon/csv/CompleteResults.htm').then(function(data){ParseCSVExport(data);});
	$j("#Time_Format").val(GetCookie("Time_Format","number"));
	RedrawAllCharts();
	ScriptUpdateLayout();
	SetConnmonStatsTitle();
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

function reload(){
	location.reload(true);
}

function getChartPeriod(period){
	var chartperiod = "daily";
	if (period == 0) chartperiod = "daily";
	else if (period == 1) chartperiod = "weekly";
	else if (period == 2) chartperiod = "monthly";
	return chartperiod;
}

function ResetZoom(){
	for(i = 0; i < metriclist.length; i++){
		var chartobj = window["LineChart_"+metriclist[i]];
		if(typeof chartobj === 'undefined' || chartobj === null){ continue; }
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
	else{
		drag = true;
		pan = false;
		DragZoom = true;
		ChartPan = false;
		buttonvalue = "Drag Zoom On";
	}
	
	for(i = 0; i < metriclist.length; i++){
		var chartobj = window["LineChart_"+metriclist[i]];
		if(typeof chartobj === 'undefined' || chartobj === null){ continue; }
		chartobj.options.plugins.zoom.zoom.drag = drag;
		chartobj.options.plugins.zoom.pan.enabled = pan;
		button.value = buttonvalue;
		chartobj.update();
	}
}

function update_status(){
	$j.ajax({
		url: '/ext/connmon/detect_update.js',
		dataType: 'script',
		timeout: 3000,
		error: function(xhr){
			setTimeout(update_status, 1000);
		},
		success: function(){
			if (updatestatus == "InProgress"){
				setTimeout(update_status, 1000);
			}
			else{
				document.getElementById("imgChkUpdate").style.display = "none";
				showhide("connmon_version_server", true);
				if(updatestatus != "None"){
					$j("#connmon_version_server").text("Updated version available: "+updatestatus);
					showhide("btnChkUpdate", false);
					showhide("btnDoUpdate", true);
				}
				else{
					$j("#connmon_version_server").text("No update available");
					showhide("btnChkUpdate", true);
					showhide("btnDoUpdate", false);
				}
			}
		}
	});
}

function CheckUpdate(){
	showhide("btnChkUpdate", false);
	document.formScriptActions.action_script.value="start_connmoncheckupdate"
	document.formScriptActions.submit();
	document.getElementById("imgChkUpdate").style.display = "";
	setTimeout(update_status, 2000);
}

function DoUpdate(){
	var action_script_tmp = "start_connmondoupdate";
	document.form.action_script.value = action_script_tmp;
	var restart_time = 10;
	document.form.action_wait.value = restart_time;
	showLoading();
	document.form.submit();
}

function SaveConfig(){
	if(Validate_All()){
		if(document.form.pingtype.value == 0){
			document.form.connmon_pingserver.value = document.form.connmon_ipaddr.value;
		}
		else if(document.form.pingtype.value == 1){
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
	else{
		return false;
	}
}

function GetVersionNumber(versiontype){
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
	else{
		return versionprop;
	}
}

function get_conntestresult_file(){
	$j.ajax({
		url: '/ext/connmon/ping-result.htm',
		dataType: 'text',
		timeout: 1000,
		error: function(xhr){
			setTimeout(get_conntestresult_file, 500);
		},
		success: function(data){
			var lines = data.trim().split('\n');
			data = lines.join('\n');
			$j("#conntest_output").html(data);
			document.getElementById("conntest_output").parentElement.parentElement.style.display = "";
		}
	});
}

function get_conf_file(){
	$j.ajax({
		url: '/ext/connmon/config.htm',
		dataType: 'text',
		error: function(xhr){
			setTimeout(get_conf_file, 1000);
		},
		success: function(data){
			var configdata=data.split("\n");
			configdata = configdata.filter(Boolean);
			
			for (var i = 0; i < configdata.length; i++){
				if(configdata[i].indexOf("PINGSERVER") == -1){
					eval("document.form.connmon_"+configdata[i].split("=")[0].toLowerCase()).value = configdata[i].split("=")[1].replace(/(\r\n|\n|\r)/gm,"");
				}
				if (configdata[i].indexOf("PINGSERVER") != -1){
					var pingserver=configdata[i].split("=")[1].replace(/(\r\n|\n|\r)/gm,"");
					document.form.connmon_pingserver.value = pingserver;
					if(Validate_IP(document.form.connmon_pingserver)){
						document.form.pingtype.value=0;
						document.form.connmon_ipaddr.value=pingserver;
					}
					else{
						document.form.pingtype.value=1;
						document.form.connmon_domain.value=pingserver;
					}
					document.form.pingtype.onchange();
				}
				else if (configdata[i].indexOf("PINGDURATION") != -1){
					pingtestdur=document.form.connmon_pingduration.value;
				}
			}
		}
	});
}

var pingcount=2;
function update_conntest(){
	pingcount++;
	$j.ajax({
		url: '/ext/connmon/detect_connmon.js',
		dataType: 'script',
		timeout: 1000,
		error: function(xhr){
			//do nothing
		},
		success: function(){
			if (connmonstatus == "InProgress"){
				showhide("imgConnTest", true);
				showhide("conntest_text", true);
				document.getElementById("conntest_text").innerHTML = "Ping test in progress - " + pingcount + "s elapsed";
			}
			else if (connmonstatus == "Done"){
				get_conntestresult_file();
				document.getElementById("conntest_text").innerHTML = "Refreshing charts...";
				pingcount=2;
				clearInterval(myinterval);
				PostConnTest();
			}
			else if (connmonstatus == "LOCKED"){
				showhide("imgConnTest", false);
				document.getElementById("conntest_text").innerHTML = "Scheduled ping test already running!";
				showhide("conntest_text", true);
				showhide("btnRunPingtest", true);
				document.getElementById("conntest_output").parentElement.parentElement.style.display = "none";
				clearInterval(myinterval);
			}
			else if (connmonstatus == "InvalidServer"){
				showhide("imgConnTest", false);
				document.getElementById("conntest_text").innerHTML = "Specified ping server is not valid";
				showhide("conntest_text", true);
				showhide("btnRunPingtest", true);
				document.getElementById("conntest_output").parentElement.parentElement.style.display = "none";
				clearInterval(myinterval);
			}
		}
	});
}

function PostConnTest(){
	currentNoCharts = 0;
	$j("#resulttable_pings").remove();
	reload_js('/ext/connmon/connjs.js');
	reload_js('/ext/connmon/connstatstext.js');
	$j("#Time_Format").val(GetCookie("Time_Format","number"));
	SetConnmonStatsTitle();
	setTimeout(RedrawAllCharts, 3000);
}

function runPingTest(){
	showhide("btnRunPingtest", false);
	$j("#conntest_output").html("");
	document.getElementById("conntest_output").parentElement.parentElement.style.display = "none";
	document.formScriptActions.action_script.value="start_connmon";
	document.formScriptActions.submit();
	showhide("imgConnTest", true);
	showhide("conntest_text", false);
	setTimeout(StartConnTestInterval, 2000);
}

var myinterval;
function StartConnTestInterval(){
	myinterval = setInterval(update_conntest, 1000);
}

function reload_js(src){
	$j('script[src="' + src + '"]').remove();
	$j('<script>').attr('src', src+'?cachebuster='+ new Date().getTime()).appendTo('head');
}

function changeAllCharts(e){
	value = e.value * 1;
	name = e.id.substring(0, e.id.indexOf("_"));
	SetCookie(e.id,value);
	for (i = 0; i < metriclist.length; i++){
		Draw_Chart(metriclist[i],titlelist[i],measureunitlist[i],bordercolourlist[i],backgroundcolourlist[i]);
	}
}

function changeChart(e){
	value = e.value * 1;
	name = e.id.substring(0, e.id.indexOf("_"));
	SetCookie(e.id,value);
	
	if(name == "Ping"){
		Draw_Chart("Ping",titlelist[0],measureunitlist[0],bordercolourlist[0],backgroundcolourlist[0]);
	}
	else if(name == "Jitter"){
		Draw_Chart("Jitter",titlelist[1],measureunitlist[1],bordercolourlist[1],backgroundcolourlist[1]);
	}
	else if(name == "LineQuality"){
		Draw_Chart("LineQuality",titlelist[2],measureunitlist[2],bordercolourlist[2],backgroundcolourlist[2]);
	}
}

function BuildLastXTable(){
	var tablehtml = '<div style="line-height:10px;">&nbsp;</div>';
	tablehtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="resulttable_pings">';
	tablehtml+='<thead class="collapsible-jquery" id="resultthead_pings">';
	tablehtml+='<tr><td colspan="2">Last 10 ping test results (click to expand/collapse)</td></tr>';
	tablehtml+='</thead>';
	tablehtml+='<tr>';
	tablehtml+='<td colspan="2" align="center" style="padding: 0px;">';
	tablehtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable StatsTable">';
	var nodata="";
	var objdataname = window["DataTimestamp"];
	if(typeof objdataname === 'undefined' || objdataname === null){nodata="true"}
	else if(objdataname.length == 0){nodata="true"}
	else if(objdataname.length == 1 && objdataname[0] == ""){nodata="true"}

	if(nodata == "true"){
		tablehtml+='<tr>';
		tablehtml+='<td colspan="4" class="nodata">';
		tablehtml+='No data to display';
		tablehtml+='</td>';
		tablehtml+='</tr>';
	}
	else{
		tablehtml+='<col style="width:185px;">';
		tablehtml+='<col style="width:185px;">';
		tablehtml+='<col style="width:185px;">';
		tablehtml+='<col style="width:185px;">';
		tablehtml+='<thead>';
		tablehtml+='<tr>';
		tablehtml+='<th class="keystatsnumber">Time</th>';
		tablehtml+='<th class="keystatsnumber">Ping (ms)</th>';
		tablehtml+='<th class="keystatsnumber">Jitter (ms)</th>';
		tablehtml+='<th class="keystatsnumber">Line Quality (%)</th>';
		tablehtml+='</tr>';
		tablehtml+='</thead>';
		
		for(i = 0; i < objdataname.length; i++){
			tablehtml+='<tr>';
			tablehtml+='<td>'+moment.unix(window["DataTimestamp"][i]).format('YYYY-MM-DD HH:mm:ss')+'</td>';
			tablehtml+='<td>'+window["DataPing"][i]+'</td>';
			tablehtml+='<td>'+window["DataJitter"][i]+'</td>';
			tablehtml+='<td>'+window["DataLineQuality"][i].replace("null","")+'</td>';
			tablehtml+='</tr>';
		};
	}
	tablehtml+='</table>';
	tablehtml+='</td>';
	tablehtml+='</tr>';
	tablehtml+='</table>';
	$j("#table_buttons2").after(tablehtml);
}
