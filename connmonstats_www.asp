<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">
<link rel="shortcut icon" href="images/favicon.png">
<link rel="icon" href="images/favicon.png">
<title>connmon</title>
<link rel="stylesheet" type="text/css" href="index_style.css">
<link rel="stylesheet" type="text/css" href="form_style.css">
<style>
p {
  font-weight: bolder;
}

thead.collapsible-jquery {
  color: white;
  padding: 0px;
  width: 100%;
  border: none;
  text-align: left;
  outline: none;
  cursor: pointer;
}

th.keystatsnumber {
  font-size: 20px !important;
  font-weight: bolder !important;
}

td.keystatsnumber {
  font-size: 20px !important;
  font-weight: bolder !important;
}

td.nodata {
  font-size: 48px !important;
  font-weight: bolder !important;
  height: 65px !important;
  font-family: Arial !important;
}

.StatsTable {
  table-layout: fixed !important;
  width: 747px !important;
  text-align: center !important;
}

.StatsTable th {
  background-color:#1F2D35 !important;
  background:#2F3A3E !important;
  border-bottom:none !important;
  border-top:none !important;
  color: white !important;
  padding: 4px !important;
  width: 740px !important;
  font-size: 11px !important;
}

.StatsTable td {
  padding: 2px !important;
  word-wrap: break-word !important;
  overflow-wrap: break-word !important;
  font-size: 12px !important;
}

.StatsTable a {
  font-weight: bolder !important;
  text-decoration: underline !important;
}

.StatsTable th:first-child,
.StatsTable td:first-child {
  border-left: none !important;
}

.StatsTable th:last-child ,
.StatsTable td:last-child {
  border-right: none !important;
}

.SettingsTable {
  text-align: left;
}

.SettingsTable input {
  text-align: left;
  margin-left: 3px !important;
}

.SettingsTable input.savebutton {
  text-align: center;
  margin-top: 5px;
  margin-bottom: 5px;
  border-right: solid 1px black;
  border-left: solid 1px black;
  border-bottom: solid 1px black;
}

.SettingsTable td.savebutton {
  border-right: solid 1px black;
  border-left: solid 1px black;
  border-bottom: solid 1px black;
  background-color:rgb(77,89,93);
}

.SettingsTable .cronbutton {
  text-align: center;
  min-width: 50px;
  width: 50px;
  height: 23px;
  vertical-align: middle;
}

.SettingsTable select {
  margin-left: 3px !important;
}

.SettingsTable label {
  margin-right: 10px !important;
  vertical-align: top !important;
}

.SettingsTable th {
  background-color: #1F2D35 !important;
  background: #2F3A3E !important;
  border-bottom: none !important;
  border-top: none !important;
  font-size: 12px !important;
  color: white !important;
  padding: 4px !important;
  font-weight: bolder !important;
  padding: 0px !important;
}

.SettingsTable td {
  word-wrap: break-word !important;
  overflow-wrap: break-word !important;
  border-right: none;
  border-left: none;
}

.SettingsTable span.settingname {
  background-color: #1F2D35 !important;
  background: #2F3A3E !important;
}

.SettingsTable td.settingname {
  border-right: solid 1px black;
  border-left: solid 1px black;
  background-color: #1F2D35 !important;
  background: #2F3A3E !important;
  width: 35% !important;
}

.SettingsTable td.settingvalue {
  text-align: left !important;
  border-right: solid 1px black;
}

.SettingsTable th:first-child{
  border-left: none !important;
}

.SettingsTable th:last-child {
  border-right: none !important;
}

.SettingsTable .invalid {
  background-color: darkred !important;
}

.SettingsTable .disabled {
  background-color: #CCCCCC !important;
  color: #888888 !important;
}

.removespacing {
  padding-left: 0px !important;
  margin-left: 0px !important;
  margin-bottom: 5px !important;
  text-align: center !important;
}

.schedulespan {
  display:inline-block !important;
  width:70px !important;
  color:#FFFFFF !important;
  font-weight: bold !important;
}

div.schedulesettings {
  margin-bottom: 5px;
}
</style>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/jquery.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/moment.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chart.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/hammerjs.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chartjs-plugin-zoom.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chartjs-plugin-annotation.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/d3.js"></script>
<script language="JavaScript" type="text/javascript" src="/state.js"></script>
<script language="JavaScript" type="text/javascript" src="/general.js"></script>
<script language="JavaScript" type="text/javascript" src="/popup.js"></script>
<script language="JavaScript" type="text/javascript" src="/help.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/detect.js"></script>
<script language="JavaScript" type="text/javascript" src="/tmhist.js"></script>
<script language="JavaScript" type="text/javascript" src="/tmmenu.js"></script>
<script language="JavaScript" type="text/javascript" src="/client_function.js"></script>
<script language="JavaScript" type="text/javascript" src="/validator.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/connmon/connjs.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/connmon/connstatstext.js"></script>
<script>
var custom_settings;
function LoadCustomSettings(){
	custom_settings = <% get_custom_settings(); %>;
	for(var prop in custom_settings) {
		if(Object.prototype.hasOwnProperty.call(custom_settings,prop)) {
			if(prop.indexOf('connmon') != -1 && prop.indexOf('connmon_version') == -1){
				eval('delete custom_settings.'+prop)
			}
		}
	}
}
var $j = jQuery.noConflict(); //avoid conflicts on John's fork (state.js)
var daysofweek = ['Mon','Tues','Wed','Thurs','Fri','Sat','Sun'];
var pingtestdur = 60;
var maxNoCharts = 27;
var currentNoCharts = 0;
var ShowLines = GetCookie('ShowLines','string');
var ShowFill = GetCookie('ShowFill','string');
if( ShowFill == '' ){
	ShowFill = 'origin';
}
var DragZoom = true;
var ChartPan = false;

Chart.defaults.global.defaultFontColor = '#CCC';
Chart.Tooltip.positioners.cursor = function(chartElements,coordinates){
	return coordinates;
};

var dataintervallist = ["raw","hour","day"];
var metriclist = ['Ping','Jitter','LineQuality'];
var titlelist = ['Ping','Jitter','Quality'];
var measureunitlist = ['ms','ms','%'];
var chartlist = ['daily','weekly','monthly'];
var timeunitlist = ['hour','day','day'];
var intervallist = [24,7,30];
var bordercolourlist = ['#fc8500','#42ecf5','#ffffff'];
var backgroundcolourlist = ['rgba(252,133,0,0.5)','rgba(66,236,245,0.5)','rgba(255,255,255,0.5)'];

function SettingHint(hintid){
	var tag_name = document.getElementsByTagName('a');
	for (var i=0; i<tag_name.length; i++){
		tag_name[i].onmouseout=nd;
	}
	hinttext='My text goes here';
	if(hintid == 1) hinttext='Hour(s) of day to run ping test<br />* for all<br />Valid numbers between 0 and 23<br />comma (,) separate for multiple<br />dash (-) separate for a range';
	if(hintid == 2) hinttext='Minute(s) of day to run ping test<br />(* for all<br />Valid numbers between 0 and 59<br />comma (,) separate for multiple<br />dash (-) separate for a range';
	return overlib(hinttext,0,0);
}

function keyHandler(e){
	if(e.keyCode == 82){
		$j(document).off('keydown');
		ResetZoom();
	}
	else if(e.keyCode == 68){
		$j(document).off('keydown');
		ToggleDragZoom(document.form.btnDragZoom);
	}
	else if(e.keyCode == 70){
		$j(document).off('keydown');
		ToggleFill();
	}
	else if(e.keyCode == 76){
		$j(document).off('keydown');
		ToggleLines();
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
		$j(forminput).removeClass('invalid');
		return true;
	}
	else{
		$j(forminput).addClass('invalid');
		return false;
	}
}

function Validate_Domain(forminput){
	var inputvalue = forminput.value;
	var inputname = forminput.name;
	if(/^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$/.test(inputvalue)){
		$j(forminput).removeClass('invalid');
		return true;
	}
	else{
		$j(forminput).addClass('invalid');
		return false;
	}
}

function Validate_PingDuration(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value*1;
	
	if(inputvalue > 60 || inputvalue < 10){
		$j(forminput).addClass('invalid');
		return false;
	}
	else{
		$j(forminput).removeClass('invalid');
		return true;
	}
}

function Validate_Schedule(forminput,hoursmins){
	var inputname = forminput.name;
	var inputvalues = forminput.value.split(',');
	var upperlimit = 0;
	
	if(hoursmins == 'hours'){
		upperlimit = 23;
	}
	else if (hoursmins == 'mins'){
		upperlimit = 59;
	}
	
	showhide('btnfixhours',false);
	showhide('btnfixmins',false);
	
	var validationfailed = 'false';
	for(var i=0; i < inputvalues.length; i++){
		if(inputvalues[i] == '*' && i == 0){
			validationfailed = 'false';
		}
		else if(inputvalues[i] == '*' && i != 0){
			validationfailed = 'true';
		}
		else if(inputvalues[0] == '*' && i > 0){
			validationfailed = 'true';
		}
		else if(inputvalues[i] == ''){
			validationfailed = 'true';
		}
		else if(inputvalues[i].startsWith('*/')){
			if(! isNaN(inputvalues[i].replace('*/','')*1)){
				if((inputvalues[i].replace('*/','')*1) > upperlimit || (inputvalues[i].replace('*/','')*1) < 0){
					validationfailed = 'true';
				}
			}
			else{
				validationfailed = 'true';
			}
		}
		else if(inputvalues[i].indexOf('-') != -1){
			if(inputvalues[i].startsWith('-')){
				validationfailed = 'true';
			}
			else{
				var inputvalues2 = inputvalues[i].split('-');
				for(var i2 = 0; i2 < inputvalues2.length; i2++){
					if(inputvalues2[i2] == ''){
						validationfailed = 'true';
					}
					else if(! isNaN(inputvalues2[i2]*1)){
						if((inputvalues2[i2]*1) > upperlimit || (inputvalues2[i2]*1) < 0){
							validationfailed = 'true';
						}
						else if((inputvalues2[i2+1]*1) < (inputvalues2[i2]*1)){
							validationfailed = 'true';
							if(hoursmins == 'hours'){
								showhide('btnfixhours',true)
							}
							else if (hoursmins == 'mins'){
								showhide('btnfixmins',true)
							}
						}
					}
					else{
						validationfailed = 'true';
					}
				}
			}
		}
		else if(! isNaN(inputvalues[i]*1)){
			if((inputvalues[i]*1) > upperlimit || (inputvalues[i]*1) < 0){
				validationfailed = 'true';
			}
		}
		else{
			validationfailed = 'true';
		}
	}
	
	if(validationfailed == 'true'){
		$j(forminput).addClass('invalid');
		return false;
	}
	else{
		$j(forminput).removeClass('invalid');
		return true;
	}
}

function Validate_ScheduleValue(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value*1;
	
	var upperlimit = 0;
	var lowerlimit = 1;
	
	var unittype = $j('#everyxselect').val();
	
	if(unittype == 'hours'){
		upperlimit = 24;
	}
	else if(unittype == 'minutes'){
		upperlimit = 30;
	}
	
	if(inputvalue > upperlimit || inputvalue < lowerlimit || forminput.value.length < 1){
		$j(forminput).addClass('invalid');
		return false;
	}
	else{
		$j(forminput).removeClass('invalid');
		return true;
	}
}

function Validate_All(){
	var validationfailed = false;
	if(! Validate_IP(document.form.connmon_ipaddr)){validationfailed=true;}
	if(! Validate_Domain(document.form.connmon_domain)){validationfailed=true;}
	if(! Validate_PingDuration(document.form.connmon_pingduration)){validationfailed=true;}
	if(document.form.schedulemode.value == 'EveryX'){
		if(! Validate_ScheduleValue(document.form.everyxvalue)) validationfailed=true;
	}
	else if(document.form.schedulemode.value == 'Custom'){
		if(! Validate_Schedule(document.form.connmon_schhours,'hours')) validationfailed=true;
		if(! Validate_Schedule(document.form.connmon_schmins,'mins')) validationfailed=true;
	}
	
	if(validationfailed){
		alert('Validation for some fields failed. Please correct invalid values and try again.');
		return false;
	}
	else{
		return true;
	}
}

function FixCron(hoursmins){
	if(hoursmins == 'hours'){
		var origvalue = document.form.connmon_schhours.value;
		document.form.connmon_schhours.value = origvalue.split('-')[0]+'-23,0-'+origvalue.split('-')[1];
		Validate_Schedule(document.form.connmon_schhours,'hours');
	}
	else if(hoursmins == 'mins'){
		var origvalue = document.form.connmon_schmins.value;
		document.form.connmon_schmins.value = origvalue.split('-')[0]+'-59,0-'+origvalue.split('-')[1];
		Validate_Schedule(document.form.connmon_schmins,'mins');
	}
}

function changePingType(forminput){
	var inputvalue = forminput.value;
	var inputname = forminput.name;
	if(inputvalue == 0){
		document.getElementById('rowip').style.display = '';
		document.getElementById('rowdomain').style.display = 'none';
	}
	else{
		document.getElementById('rowip').style.display = 'none';
		document.getElementById('rowdomain').style.display = '';
	}
}

function Draw_Chart_NoData(txtchartname){
	document.getElementById('divLineChart_'+txtchartname).width = '730';
	document.getElementById('divLineChart_'+txtchartname).height = '500';
	document.getElementById('divLineChart_'+txtchartname).style.width = '730px';
	document.getElementById('divLineChart_'+txtchartname).style.height = '500px';
	var ctx = document.getElementById('divLineChart_'+txtchartname).getContext('2d');
	ctx.save();
	ctx.textAlign = 'center';
	ctx.textBaseline = 'middle';
	ctx.font = 'normal normal bolder 48px Arial';
	ctx.fillStyle = 'white';
	ctx.fillText('No data to display',365,250);
	ctx.restore();
}

function Draw_Chart(txtchartname,txttitle,txtunity,bordercolourname,backgroundcolourname){
	var chartperiod = getChartPeriod($j('#'+txtchartname+'_Period option:selected').val());
	var chartinterval = getChartInterval($j("#" + txtchartname + "_Interval option:selected").val());
	var txtunitx = timeunitlist[$j('#'+txtchartname+'_Period option:selected').val()];
	var numunitx = intervallist[$j('#'+txtchartname+'_Period option:selected').val()];
	var chartxaxismax = null;
	var chartaxismin = moment().subtract(numunitx,txtunitx+'s');
	var charttype = "line";
	var dataobject = window[txtchartname+'_'+chartinterval+'_'+chartperiod];
	
	if(typeof dataobject === 'undefined' || dataobject === null){ Draw_Chart_NoData(txtchartname); return; }
	if(dataobject.length == 0){ Draw_Chart_NoData(txtchartname); return; }
	
	var chartLabels = dataobject.map(function(d){return d.Metric});
	var chartData = dataobject.map(function(d){return {x: d.Time,y: d.Value}});
	var objchartname = window['LineChart_'+txtchartname];
	
	var timeaxisformat = getTimeFormat($j('#Time_Format option:selected').val(),'axis');
	var timetooltipformat = getTimeFormat($j('#Time_Format option:selected').val(),'tooltip');
	
	if(chartinterval == 'day'){
		charttype = 'bar';
		chartxaxismax = moment().startOf('day').add(12, 'hours');
	}
	
	if(chartperiod == 'daily' && chartinterval == 'day'){
		txtunitx = 'day';
		numunitx = 1;
		chartxaxismax = moment().startOf('day').add(12, 'hours');
		chartaxismin = moment().startOf('day').subtract(9, 'hours');
	}
	
	factor = 0;
	if(txtunitx == 'hour'){
		factor = 60*60*1000;
	}
	else if(txtunitx == 'day'){
		factor = 60*60*24*1000;
	}
	if(objchartname != undefined) objchartname.destroy();
	var ctx = document.getElementById('divLineChart_'+txtchartname).getContext('2d');
	var lineOptions = {
		segmentShowStroke : false,
		segmentStrokeColor : '#000',
		animationEasing : 'easeOutQuart',
		animationSteps : 100,
		maintainAspectRatio: false,
		animateScale : true,
		hover: { mode: 'point' },
		legend: { display: false,position: 'bottom',onClick: null },
		title: { display: true,text: txttitle },
		tooltips: {
			callbacks: {
				title: function (tooltipItem,data){
					if(chartinterval == 'day'){
						return moment(tooltipItem[0].xLabel,'X').format('YYYY-MM-DD');
					}
					else{
						return moment(tooltipItem[0].xLabel,'X').format(timetooltipformat);
					}
				},
				label: function (tooltipItem,data){ return round(data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].y,2).toFixed(2)+' '+txtunity;}
			},
			mode: 'point',
			position: 'cursor',
			intersect: true
		},
		scales: {
			xAxes: [{
				type: 'time',
				gridLines: { display: true,color: '#282828' },
				ticks: {
					min: chartaxismin,
					max: chartxaxismax,
					display: true
				},
				time: {
					parser: 'X',
					unit: txtunitx,
					stepSize: 1,
					displayFormats: timeaxisformat
				}
			}],
			yAxes: [{
				type: getChartScale($j('#'+txtchartname+'_Scale option:selected').val()),
				gridLines: { display: false,color: '#282828' },
				scaleLabel: { display: false,labelString: txtunity },
				ticks: {
					display: true,
					beginAtZero: true,
					max: getYAxisMax(txtchartname),
					labels: {
						index: ['min','max'],
						removeEmptyLines: true
					},
					userCallback: LogarithmicFormatter
				}
			}]
		},
		plugins: {
			zoom: {
				pan: {
					enabled: ChartPan,
					mode: 'xy',
					rangeMin: {
						x: new Date().getTime() - (factor * numunitx),
						y: 0
					},
					rangeMax: {
						x: new Date().getTime(),
						y: getLimit(chartData,'y','max',false)+getLimit(chartData,'y','max',false)*0.1
					},
				},
				zoom: {
					enabled: true,
					drag: DragZoom,
					mode: 'xy',
					rangeMin: {
						x: new Date().getTime() - (factor * numunitx),
						y: 0
					},
					rangeMax: {
						x: new Date().getTime(),
						y: getLimit(chartData,'y','max',false)+getLimit(chartData,'y','max',false)*0.1
					},
					speed: 0.1
				}
			}
		},
		annotation: {
			drawTime: 'afterDatasetsDraw',
			annotations: [{
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'y-axis-0',
				value: getAverage(chartData),
				borderColor: bordercolourname,
				borderWidth: 1,
				borderDash: [5,5],
				label: {
					backgroundColor: 'rgba(0,0,0,0.3)',
					fontFamily: 'sans-serif',
					fontSize: 10,
					fontStyle: 'bold',
					fontColor: '#fff',
					xPadding: 6,
					yPadding: 6,
					cornerRadius: 6,
					position: 'center',
					enabled: true,
					xAdjust: 0,
					yAdjust: 0,
					content: 'Avg='+round(getAverage(chartData),2).toFixed(2)+txtunity
				}
			},
			{
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'y-axis-0',
				value: getLimit(chartData,'y','max',true),
				borderColor: bordercolourname,
				borderWidth: 1,
				borderDash: [5,5],
				label: {
					backgroundColor: 'rgba(0,0,0,0.3)',
					fontFamily: 'sans-serif',
					fontSize: 10,
					fontStyle: 'bold',
					fontColor: '#fff',
					xPadding: 6,
					yPadding: 6,
					cornerRadius: 6,
					position: 'right',
					enabled: true,
					xAdjust: 15,
					yAdjust: 0,
					content: 'Max='+round(getLimit(chartData,'y','max',true),2).toFixed(2)+txtunity
				}
			},
			{
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'y-axis-0',
				value: getLimit(chartData,'y','min',true),
				borderColor: bordercolourname,
				borderWidth: 1,
				borderDash: [5,5],
				label: {
					backgroundColor: 'rgba(0,0,0,0.3)',
					fontFamily: 'sans-serif',
					fontSize: 10,
					fontStyle: 'bold',
					fontColor: '#fff',
					xPadding: 6,
					yPadding: 6,
					cornerRadius: 6,
					position: 'left',
					enabled: true,
					xAdjust: 15,
					yAdjust: 0,
					content: 'Min='+round(getLimit(chartData,'y','min',true),2).toFixed(2)+txtunity
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
			borderColor: bordercolourname
		}]
	};
	objchartname = new Chart(ctx,{
		type: charttype,
		options: lineOptions,
		data: lineDataset
	});
	window['LineChart_'+txtchartname]=objchartname;
}

function LogarithmicFormatter(tickValue,index,ticks){
	var unit = this.options.scaleLabel.labelString;
	if(this.type != 'logarithmic'){
		if(! isNaN(tickValue)){
			return round(tickValue,2).toFixed(2)+' '+unit;
		}
		else{
			return tickValue+' '+unit;
		}
	}
	else{
		var labelOpts =  this.options.ticks.labels || {};
		var labelIndex = labelOpts.index || ['min','max'];
		var labelSignificand = labelOpts.significand || [1,2,5];
		var significand = tickValue / (Math.pow(10,Math.floor(Chart.helpers.log10(tickValue))));
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
				return '0'+' '+unit;
			}
			else{
				if(! isNaN(tickValue)){
					return round(tickValue,2).toFixed(2)+' '+unit;
				}
				else{
					return tickValue+' '+unit;
				}
			}
		}
		return emptyTick;
	}
};

function getLimit(datasetname,axis,maxmin,isannotation){
	var limit = 0;
	var values;
	if(axis == 'x'){
		values = datasetname.map(function(o){ return o.x } );
	}
	else{
		values = datasetname.map(function(o){ return o.y } );
	}
	
	if(maxmin == 'max'){
		limit = Math.max.apply(Math,values);
	}
	else{
		limit = Math.min.apply(Math,values);
	}
	if(maxmin == 'max' && limit == 0 && isannotation == false){
		limit = 1;
	}
	return limit;
}

function getYAxisMax(chartname){
	if(chartname == 'LineQuality'){
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

function round(value,decimals){
	return Number(Math.round(value+'e'+decimals)+'e-'+decimals);
}

function ToggleLines(){
	if(ShowLines == ''){
		ShowLines = 'line';
		SetCookie('ShowLines','line');
	}
	else{
		ShowLines = '';
		SetCookie('ShowLines','');
	}
	for(var i = 0; i < metriclist.length; i++){
		for(var i3 = 0; i3 < 3; i3++){
			window['LineChart_'+metriclist[i]].options.annotation.annotations[i3].type=ShowLines;
		}
		window['LineChart_'+metriclist[i]].update();
	}
}

function ToggleFill(){
	if(ShowFill == 'false'){
		ShowFill = 'origin';
		SetCookie('ShowFill','origin');
	}
	else{
		ShowFill = 'false';
		SetCookie('ShowFill','false');
	}
	for(var i = 0; i < metriclist.length; i++){
		window['LineChart_'+metriclist[i]].data.datasets[0].fill=ShowFill;
		window['LineChart_'+metriclist[i]].update();
	}
}

function RedrawAllCharts(){
	for(var i = 0; i < metriclist.length; i++){
		for(var i2 = 0; i2 < chartlist.length; i2++){
			for(var i3 = 0; i3 < dataintervallist.length; i3++){
				d3.csv('/ext/connmon/csv/'+metriclist[i]+'_'+dataintervallist[i3]+'_'+chartlist[i2]+'.htm').then(SetGlobalDataset.bind(null,metriclist[i]+'_'+dataintervallist[i3]+'_'+chartlist[i2]));
			}
		}
	}
}

function SetGlobalDataset(txtchartname,dataobject){
	window[txtchartname] = dataobject;
	currentNoCharts++;
	if(currentNoCharts == maxNoCharts){
		showhide('imgConnTest',false);
		showhide('conntest_text',false);
		showhide('btnRunPingtest',true);
		BuildLastXTable();
		for(var i = 0; i < metriclist.length; i++){
			$j('#'+metriclist[i]+'_Interval').val(GetCookie(metriclist[i]+'_Interval','number'));
			changePeriod(document.getElementById(metriclist[i]+'_Interval'));
			$j('#'+metriclist[i]+'_Period').val(GetCookie(metriclist[i]+'_Period','number'));
			$j('#'+metriclist[i]+'_Scale').val(GetCookie(metriclist[i]+'_Scale','number'));
			Draw_Chart(metriclist[i],titlelist[i],measureunitlist[i],bordercolourlist[i],backgroundcolourlist[i]);
		}
		AddEventHandlers();
	}
}

function getChartScale(scale){
	var chartscale = '';
	if(scale == 0){
		chartscale = 'linear';
	}
	else if(scale == 1){
		chartscale = 'logarithmic';
	}
	return chartscale;
}

function getChartInterval(layout){
	var charttype = 'raw';
	if(layout == 0) charttype = 'raw';
	else if(layout == 1) charttype = 'hour';
	else if(layout == 2) charttype = 'day';
	return charttype;
}

function getTimeFormat(value,format){
	var timeformat;
	
	if(format == 'axis'){
		if(value == 0){
			timeformat = {
				millisecond: 'HH:mm:ss.SSS',
				second: 'HH:mm:ss',
				minute: 'HH:mm',
				hour: 'HH:mm'
			}
		}
		else if(value == 1){
			timeformat = {
				millisecond: 'h:mm:ss.SSS A',
				second: 'h:mm:ss A',
				minute: 'h:mm A',
				hour: 'h A'
			}
		}
	}
	else if(format == 'tooltip'){
		if(value == 0){
			timeformat = 'YYYY-MM-DD HH:mm:ss';
		}
		else if(value == 1){
			timeformat = 'YYYY-MM-DD h:mm:ss A';
		}
	}
	
	return timeformat;
}

function GetCookie(cookiename,returntype){
	if(cookie.get('conn_'+cookiename) != null){
		return cookie.get('conn_'+cookiename);
	}
	else{
		if(returntype == 'string'){
			return '';
		}
		else if(returntype == 'number'){
			return 0;
		}
	}
}

function SetCookie(cookiename,cookievalue){
	cookie.set('conn_'+cookiename,cookievalue,10 * 365);
}

function AddEventHandlers(){
	$j('.collapsible-jquery').off('click').on('click',function(){
		$j(this).siblings().toggle('fast',function(){
			if($j(this).css('display') == 'none'){
				SetCookie($j(this).siblings()[0].id,'collapsed');
			}
			else{
				SetCookie($j(this).siblings()[0].id,'expanded');
			}
		})
	});

	$j('.collapsible-jquery').each(function(index,element){
		if(GetCookie($j(this)[0].id,'string') == 'collapsed'){
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
	$j.each(a,function(){
		if(o[this.name] !== undefined && this.name.indexOf('connmon') != -1 && this.name.indexOf('version') == -1 && this.name.indexOf('ipaddr') == -1 && this.name.indexOf('domain') == -1 && this.name.indexOf('schdays') == -1){
			if(!o[this.name].push){
				o[this.name] = [o[this.name]];
			}
			o[this.name].push(this.value || '');
		} else if(this.name.indexOf('connmon') != -1 && this.name.indexOf('version') == -1 && this.name.indexOf('ipaddr') == -1 && this.name.indexOf('domain') == -1 && this.name.indexOf('schdays') == -1){
			o[this.name] = this.value || '';
		}
	});
	var schdays = [];
	$j.each($j('input[name="connmon_schdays"]:checked'),function(){
		schdays.push($j(this).val());
	});
	var schdaysstring = schdays.join(',');
	if(schdaysstring == 'Mon,Tues,Wed,Thurs,Fri,Sat,Sun'){
		schdaysstring = '*';
	}
	o['connmon_schdays'] = schdaysstring;
	return o;
};

function SetCurrentPage(){
	document.form.next_page.value = window.location.pathname.substring(1);
	document.form.current_page.value = window.location.pathname.substring(1);
}

function ParseCSVExport(data){
	var csvContent = 'Timestamp,Ping,Jitter,LineQuality\n';
	for(var i = 0; i < data.length; i++){
		var dataString = data[i].Timestamp+','+data[i].Ping+','+data[i].Jitter+','+data[i].LineQuality;
		csvContent += i < data.length-1 ? dataString+'\n' : dataString;
	}
	document.getElementById('aExport').href='data:text/csv;charset=utf-8,'+encodeURIComponent(csvContent);
}

function ErrorCSVExport(){
	document.getElementById('aExport').href='javascript:alert(\'Error exporting CSV, please refresh the page and try again\')';
}

function initial(){
	SetCurrentPage();
	LoadCustomSettings();
	show_menu();
	get_conf_file();
	d3.csv('/ext/connmon/csv/CompleteResults.htm').then(function(data){ParseCSVExport(data);}).catch(function(){ErrorCSVExport();});
	$j('#Time_Format').val(GetCookie('Time_Format','number'));
	RedrawAllCharts();
	ScriptUpdateLayout();
	SetConnmonStatsTitle();
}

function ScriptUpdateLayout(){
	var localver = GetVersionNumber('local');
	var serverver = GetVersionNumber('server');
	$j('#connmon_version_local').text(localver);
	
	if(localver != serverver && serverver != 'N/A'){
		$j('#connmon_version_server').text('Updated version available: '+serverver);
		showhide('btnChkUpdate',false);
		showhide('connmon_version_server',true);
		showhide('btnDoUpdate',true);
	}
}

function reload(){
	location.reload(true);
}

function getChartPeriod(period){
	var chartperiod = 'daily';
	if(period == 0) chartperiod = 'daily';
	else if(period == 1) chartperiod = 'weekly';
	else if(period == 2) chartperiod = 'monthly';
	return chartperiod;
}

function ResetZoom(){
	for(var i = 0; i < metriclist.length; i++){
		var chartobj = window['LineChart_'+metriclist[i]];
		if(typeof chartobj === 'undefined' || chartobj === null){ continue; }
		chartobj.resetZoom();
	}
}

function ToggleDragZoom(button){
	var drag = true;
	var pan = false;
	var buttonvalue = '';
	if(button.value.indexOf('On') != -1){
		drag = false;
		pan = true;
		DragZoom = false;
		ChartPan = true;
		buttonvalue = 'Drag Zoom Off';
	}
	else{
		drag = true;
		pan = false;
		DragZoom = true;
		ChartPan = false;
		buttonvalue = 'Drag Zoom On';
	}
	
	for(var i = 0; i < metriclist.length; i++){
		var chartobj = window['LineChart_'+metriclist[i]];
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
			setTimeout(update_status,1000);
		},
		success: function(){
			if(updatestatus == 'InProgress'){
				setTimeout(update_status,1000);
			}
			else{
				document.getElementById('imgChkUpdate').style.display = 'none';
				showhide('connmon_version_server',true);
				if(updatestatus != 'None'){
					$j('#connmon_version_server').text('Updated version available: '+updatestatus);
					showhide('btnChkUpdate',false);
					showhide('btnDoUpdate',true);
				}
				else{
					$j('#connmon_version_server').text('No update available');
					showhide('btnChkUpdate',true);
					showhide('btnDoUpdate',false);
				}
			}
		}
	});
}

function CheckUpdate(){
	showhide('btnChkUpdate',false);
	document.formScriptActions.action_script.value='start_connmoncheckupdate'
	document.formScriptActions.submit();
	document.getElementById('imgChkUpdate').style.display = '';
	setTimeout(update_status,2000);
}

function DoUpdate(){
	document.form.action_script.value = 'start_connmondoupdate';
	document.form.action_wait.value = 10;
	showLoading();
	document.form.submit();
}

function SaveConfig(){
	if(Validate_All()){
		$j('[name*=connmon_]').prop('disabled',false);
		
		if(document.form.pingtype.value == 0){
			document.form.connmon_pingserver.value = document.form.connmon_ipaddr.value;
		}
		else if(document.form.pingtype.value == 1){
			document.form.connmon_pingserver.value = document.form.connmon_domain.value;
		}
		
		if(document.form.schedulemode.value == 'EveryX'){
			if(document.form.everyxselect.value == 'hours'){
				var everyxvalue = document.form.everyxvalue.value*1;
				document.form.connmon_schmins.value = 0;
				if(everyxvalue == 24){
					document.form.connmon_schhours.value = 0;
				}
				else{
					document.form.connmon_schhours.value = '*/'+everyxvalue;
				}
			}
			else if(document.form.everyxselect.value == 'minutes'){
				document.form.connmon_schhours.value = '*';
				var everyxvalue = document.form.everyxvalue.value*1;
				document.form.connmon_schmins.value = '*/'+everyxvalue;
			}
		}
		
		document.getElementById('amng_custom').value = JSON.stringify($j('form').serializeObject());
		document.form.action_script.value = 'start_connmonconfig';
		document.form.action_wait.value = 5;
		showLoading();
		document.form.submit();
	}
	else{
		return false;
	}
}

function GetVersionNumber(versiontype){
	var versionprop;
	if(versiontype == 'local'){
		versionprop = custom_settings.connmon_version_local;
	}
	else if(versiontype == 'server'){
		versionprop = custom_settings.connmon_version_server;
	}
	
	if(typeof versionprop == 'undefined' || versionprop == null){
		return 'N/A';
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
			setTimeout(get_conntestresult_file,500);
		},
		success: function(data){
			var lines = data.trim().split('\n');
			data = lines.join('\n');
			$j('#conntest_output').html(data);
			document.getElementById('conntest_output').parentElement.parentElement.style.display = '';
		}
	});
}

function get_conf_file(){
	$j.ajax({
		url: '/ext/connmon/config.htm',
		dataType: 'text',
		error: function(xhr){
			setTimeout(get_conf_file,1000);
		},
		success: function(data){
			var configdata=data.split('\n');
			configdata = configdata.filter(Boolean);
			
			for(var i = 0; i < configdata.length; i++){
				let settingname = configdata[i].split('=')[0].toLowerCase();
				let settingvalue = configdata[i].split('=')[1].replace(/(\r\n|\n|\r)/gm,'');
				
				if(configdata[i].indexOf('PINGSERVER') != -1){
					var pingserver=settingvalue;
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
				else if(configdata[i].indexOf('SCHDAYS') != -1){
					if(settingvalue == '*'){
						for(var i2 = 0; i2 < daysofweek.length; i2++){
							$j('#connmon_'+daysofweek[i2].toLowerCase()).prop('checked',true);
						}
					}
					else{
						var schdayarray = settingvalue.split(',');
						for(var i2 = 0; i2 < schdayarray.length; i2++){
							$j('#connmon_'+schdayarray[i2].toLowerCase()).prop('checked',true);
						}
					}
				}
				else{
					eval('document.form.connmon_'+settingname).value = settingvalue;
				}
				
				if(configdata[i].indexOf('AUTOMATED') != -1){
					AutomaticTestEnableDisable($j('#connmon_auto_'+document.form.connmon_automated.value)[0]);
				}
				
				if(configdata[i].indexOf('PINGDURATION') != -1){
					pingtestdur=document.form.connmon_pingduration.value;
				}
			}
			
			if($j('[name=connmon_schhours]').val().indexOf('/') != -1 && $j('[name=connmon_schmins]').val() == 0){
				document.form.schedulemode.value = 'EveryX';
				document.form.everyxselect.value = 'hours';
				document.form.everyxvalue.value = $j('[name=connmon_schhours]').val().split('/')[1];
			}
			else if($j('[name=connmon_schmins]').val().indexOf('/') != -1 && $j('[name=connmon_schhours]').val() == '*'){
				document.form.schedulemode.value = 'EveryX';
				document.form.everyxselect.value = 'minutes';
				document.form.everyxvalue.value = $j('[name=connmon_schmins]').val().split('/')[1];
			}
			else{
				document.form.schedulemode.value = 'Custom';
			}
			ScheduleModeToggle($j('#schmode_'+$j('[name=schedulemode]:checked').val().toLowerCase())[0]);
		}
	});
}

function AutomaticTestEnableDisable(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value;
	var prefix = inputname.substring(0,inputname.indexOf('_'));
	
	var fieldnames = ['schhours','schmins'];
	var fieldnames2 = ['schedulemode','everyxselect','everyxvalue'];
	
	if(inputvalue == 'false'){
		for (var i = 0; i < fieldnames.length; i++){
			$j('input[name='+prefix+'_'+fieldnames[i]+']').addClass('disabled');
			$j('input[name='+prefix+'_'+fieldnames[i]+']').prop('disabled',true);
		}
		for (var i = 0; i < daysofweek.length; i++){
			$j('#'+prefix+'_'+daysofweek[i].toLowerCase()).prop('disabled',true);
		}
		for (var i = 0; i < fieldnames2.length; i++){
			$j('[name='+fieldnames2[i]+']').addClass('disabled');
			$j('[name='+fieldnames2[i]+']').prop('disabled',true);
		}
	}
	else if(inputvalue == 'true'){
		for (var i = 0; i < fieldnames.length; i++){
			$j('input[name='+prefix+'_'+fieldnames[i]+']').removeClass('disabled');
			$j('input[name='+prefix+'_'+fieldnames[i]+']').prop('disabled',false);
		}
		for (var i = 0; i < daysofweek.length; i++){
			$j('#'+prefix+'_'+daysofweek[i].toLowerCase()).prop('disabled',false);
		}
		for (var i = 0; i < fieldnames2.length; i++){
			$j('[name='+fieldnames2[i]+']').removeClass('disabled');
			$j('[name='+fieldnames2[i]+']').prop('disabled',false);
		}
	}
}

function ScheduleModeToggle(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value;
	
	if(inputvalue == 'EveryX'){
		showhide('schfrequency',true);
		showhide('schcustom',false);
		if($j('#everyxselect').val() == 'hours'){
			showhide('spanxhours',true);
			showhide('spanxminutes',false);
		}
		else if($j('#everyxselect').val() == 'minutes'){
			showhide('spanxhours',false);
			showhide('spanxminutes',true);
		}
	}
	else if(inputvalue == 'Custom'){
		showhide('schfrequency',false);
		showhide('schcustom',true);
	}
}

function EveryXToggle(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value;
	
	if(inputvalue == 'hours'){
		showhide('spanxhours',true);
		showhide('spanxminutes',false);
	}
	else if(inputvalue == 'minutes'){
		showhide('spanxhours',false);
		showhide('spanxminutes',true);
	}
	
	Validate_ScheduleValue($j('[name=everyxvalue]')[0]);
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
			if(connmonstatus == 'InProgress'){
				showhide('imgConnTest',true);
				showhide('conntest_text',true);
				document.getElementById('conntest_text').innerHTML = 'Ping test in progress - '+pingcount+'s elapsed';
			}
			else if(connmonstatus == 'Done'){
				get_conntestresult_file();
				document.getElementById('conntest_text').innerHTML = 'Refreshing charts...';
				pingcount=2;
				clearInterval(myinterval);
				PostConnTest();
			}
			else if(connmonstatus == 'LOCKED'){
				showhide('imgConnTest',false);
				document.getElementById('conntest_text').innerHTML = 'Scheduled ping test already running!';
				showhide('conntest_text',true);
				showhide('btnRunPingtest',true);
				document.getElementById('conntest_output').parentElement.parentElement.style.display = 'none';
				clearInterval(myinterval);
			}
			else if(connmonstatus == 'InvalidServer'){
				showhide('imgConnTest',false);
				document.getElementById('conntest_text').innerHTML = 'Specified ping server is not valid';
				showhide('conntest_text',true);
				showhide('btnRunPingtest',true);
				document.getElementById('conntest_output').parentElement.parentElement.style.display = 'none';
				clearInterval(myinterval);
			}
		}
	});
}

function PostConnTest(){
	currentNoCharts = 0;
	$j('#resulttable_pings').remove();
	reload_js('/ext/connmon/connjs.js');
	reload_js('/ext/connmon/connstatstext.js');
	$j('#Time_Format').val(GetCookie('Time_Format','number'));
	SetConnmonStatsTitle();
	setTimeout(RedrawAllCharts,3000);
}

function runPingTest(){
	showhide('btnRunPingtest',false);
	$j('#conntest_output').html('');
	document.getElementById('conntest_output').parentElement.parentElement.style.display = 'none';
	document.formScriptActions.action_script.value='start_connmon';
	document.formScriptActions.submit();
	showhide('imgConnTest',true);
	showhide('conntest_text',false);
	setTimeout(StartConnTestInterval,2000);
}

var myinterval;
function StartConnTestInterval(){
	myinterval = setInterval(update_conntest,1000);
}

function reload_js(src){
	$j('script[src="'+src+'"]').remove();
	$j('<script>').attr('src',src+'?cachebuster='+ new Date().getTime()).appendTo('head');
}

function changeAllCharts(e){
	value = e.value * 1;
	name = e.id.substring(0,e.id.indexOf('_'));
	SetCookie(e.id,value);
	for(var i = 0; i < metriclist.length; i++){
		Draw_Chart(metriclist[i],titlelist[i],measureunitlist[i],bordercolourlist[i],backgroundcolourlist[i]);
	}
}

function changeChart(e){
	value = e.value * 1;
	name = e.id.substring(0,e.id.indexOf('_'));
	SetCookie(e.id,value);
	
	if(name == 'Ping'){
		Draw_Chart('Ping',titlelist[0],measureunitlist[0],bordercolourlist[0],backgroundcolourlist[0]);
	}
	else if(name == 'Jitter'){
		Draw_Chart('Jitter',titlelist[1],measureunitlist[1],bordercolourlist[1],backgroundcolourlist[1]);
	}
	else if(name == 'LineQuality'){
		Draw_Chart('LineQuality',titlelist[2],measureunitlist[2],bordercolourlist[2],backgroundcolourlist[2]);
	}
}

function changePeriod(e){
	value = e.value * 1;
	name = e.id.substring(0,e.id.indexOf('_'));
	if(value == 2){
		$j('select[id="'+name+'_Period"] option:contains(24)').text("Today");
	}
	else{
		$j('select[id="'+name+'_Period"] option:contains("Today")').text("Last 24 hours");
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
	var nodata='';
	var objdataname = window['DataTimestamp'];
	if(typeof objdataname === 'undefined' || objdataname === null){nodata='true'}
	else if(objdataname.length == 0){nodata='true'}
	else if(objdataname.length == 1 && objdataname[0] == ''){nodata='true'}

	if(nodata == 'true'){
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
		
		for(var i = 0; i < objdataname.length; i++){
			tablehtml+='<tr>';
			tablehtml+='<td>'+moment.unix(window['DataTimestamp'][i]).format('YYYY-MM-DD HH:mm:ss')+'</td>';
			tablehtml+='<td>'+window['DataPing'][i]+'</td>';
			tablehtml+='<td>'+window['DataJitter'][i]+'</td>';
			tablehtml+='<td>'+window['DataLineQuality'][i].replace('null','')+'</td>';
			tablehtml+='</tr>';
		};
	}
	tablehtml+='</table>';
	tablehtml+='</td>';
	tablehtml+='</tr>';
	tablehtml+='</table>';
	$j('#table_config').after(tablehtml);
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
<input type="hidden" name="action_wait" value="45">
<input type="hidden" name="first_time" value="">
<input type="hidden" name="SystemCmd" value="">
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>">
<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>">
<input type="hidden" name="amng_custom" id="amng_custom" value="">
<input type="hidden" name="connmon_pingserver" id="connmon_pingserver" value="">
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
<div class="formfonttitle" id="scripttitle" style="text-align:center;">connmon</div>
<div id="statstitle" style="text-align:center;">Stats last updated:</div>
<div style="margin:10px 0 10px 5px;" class="splitLine"></div>
<div class="formfontdesc">connmon is an internet connection monitoring tool for AsusWRT Merlin with charts for daily, weekly and monthly summaries.</div>
<table width="100%" border="1" align="center" cellpadding="2" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:0px;" id="table_buttons">
<thead class="collapsible-jquery" id="scripttools">
<tr><td colspan="2">Utilities (click to expand/collapse)</td></tr>
</thead>
<tr>
<th width="20%">Version information</th>
<td>
<span id="connmon_version_local" style="color:#FFFFFF;"></span>
&nbsp;&nbsp;&nbsp;
<span id="connmon_version_server" style="display:none;">Update version</span>
&nbsp;&nbsp;&nbsp;
<input type="button" class="button_gen" onclick="CheckUpdate();" value="Check" id="btnChkUpdate">
<img id="imgChkUpdate" style="display:none;vertical-align:middle;" src="images/InternetScan.gif"/>
<input type="button" class="button_gen" onclick="DoUpdate();" value="Update" id="btnDoUpdate" style="display:none;">
&nbsp;&nbsp;&nbsp;
</td>
</tr>
<tr>
<th width="20%">Export</th>
<td>
<a id="aExport" href="" download="connmon.csv"><input type="button" value="Export to CSV" class="button_gen" name="btnExport"></a>
</td>
</tr>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:0px;" id="table_manualpingtest">
<thead class="collapsible-jquery" id="thead_manualpingtest">
<tr><td colspan="2">Manual ping test (click to expand/collapse)</td></tr>
</thead>
<tr>
<th width="20%">Ping test</th>
<td>
<input type="button" onclick="runPingTest();" value="Run ping test" class="button_gen" name="btnRunPingtest" id="btnRunPingtest">
<img id="imgConnTest" style="display:none;vertical-align:middle;" src="images/InternetScan.gif"/>
&nbsp;&nbsp;&nbsp;
<span id="conntest_text" style="display:none;"></span>
</td>
</tr>
<tr style="display:none;"><td colspan="2" style="padding: 0px;">
<textarea cols="63" rows="4" wrap="off" readonly="readonly" id="conntest_output" class="textarea_log_table" style="border:0px;font-family:Courier New, Courier, mono; font-size:11px;overflow-y:auto;overflow-x:hidden;">Ping test output</textarea>
</td></tr>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="2" cellspacing="0" bordercolor="#6b8fa3" class="FormTable SettingsTable" style="border:0px;" id="table_config">
<thead class="collapsible-jquery" id="scriptconfig">
<tr><td colspan="2">Configuration (click to expand/collapse)</td></tr>
</thead>
<tr class="even">
<td class="settingname">Ping destination type</td>
<td class="settingvalue">
<select style="width:125px" class="input_option" onchange="changePingType(this)" id="pingtype">
<option value="0">IP Address</option>
<option value="1">Domain</option>
</select>
</td>
</tr>
<tr class="even" id="rowip">
<td class="settingname">IP Address</td>
<td class="settingvalue">
<input autocomplete="off" type="text" maxlength="15" class="input_15_table removespacing" name="connmon_ipaddr" value="8.8.8.8" onkeypress="return validator.isIPAddr(this,event)" onblur="Validate_IP(this)" data-lpignore="true" />
</td>
</tr>
<tr class="even" id="rowdomain">
<td class="settingname">Domain</td>
<td class="settingvalue">
<input autocorrect="off" autocapitalize="off" type="text" maxlength="255" class="input_32_table removespacing" name="connmon_domain" value="google.co.uk" onkeypress="return validator.isString(this,event);" onblur="Validate_Domain(this)" data-lpignore="true" />
</td>
</tr>
<tr class="even" id="rowpingdur">
<td class="settingname">Ping test duration</td>
<td class="settingvalue">
<input autocomplete="off" type="text" maxlength="2" class="input_3_table removespacing" name="connmon_pingduration" value="60" onkeypress="return validator.isNumber(this,event)" onblur="Validate_PingDuration(this)" />
seconds <span style="color:#FFCC00;">(between 10 and 60, default: 60)</span>
</td>
</tr>
<tr class="even" id="rowautomatedtests">
<td class="settingname">Enable automatic ping tests</td>
<td class="settingvalue">
<input type="radio" name="connmon_automated" id="connmon_auto_true" onchange="AutomaticTestEnableDisable(this)" class="input" value="true" checked>
<label for="connmon_auto_true">Yes</label>
<input type="radio" name="connmon_automated" id="connmon_auto_false" onchange="AutomaticTestEnableDisable(this)" class="input" value="false">
<label for="connmon_auto_false">No</label>
</td>
</tr>
<tr class="even" id="rowschedule">
<td class="settingname">Schedule for automatic ping tests</td>
<td class="settingvalue">
<div class="schedulesettings" id="schdays">
<span class="schedulespan" style="vertical-align:top;">Day(s)</span>
<input type="checkbox" name="connmon_schdays" id="connmon_mon" class="input" value="Mon" style="margin-left:0px;"><label for="connmon_mon">Mon</label>
<input type="checkbox" name="connmon_schdays" id="connmon_tues" class="input" value="Tues"><label for="connmon_tues">Tues</label>
<input type="checkbox" name="connmon_schdays" id="connmon_wed" class="input" value="Wed"><label for="connmon_wed">Wed</label>
<input type="checkbox" name="connmon_schdays" id="connmon_thurs" class="input" value="Thurs"><label for="connmon_thurs">Thurs</label>
<input type="checkbox" name="connmon_schdays" id="connmon_fri" class="input" value="Fri"><label for="connmon_fri">Fri</label>
<input type="checkbox" name="connmon_schdays" id="connmon_sat" class="input" value="Sat"><label for="connmon_sat">Sat</label>
<input type="checkbox" name="connmon_schdays" id="connmon_sun" class="input" value="Sun"><label for="connmon_sun">Sun</label>
</div>
<div class="schedulesettings" id="schmode">
<span class="schedulespan" style="vertical-align:top;">Mode</span>
<input type="radio" onchange="ScheduleModeToggle(this)" name="schedulemode" id="schmode_everyx" class="input" value="EveryX" checked><label for="schmode_everyx">Every X hours/minutes</label>
<input type="radio" onchange="ScheduleModeToggle(this)" name="schedulemode" id="schmode_custom" class="input" value="Custom"><label for="schmode_custom">Custom</label>
</div>
<div style="margin-bottom:0px;" class="schedulesettings" id="schfrequency">
<span class="schedulespan">Frequency</span>
<span style="color:#FFFFFF;margin-left:3px;">Every </span>
<input autocomplete="off" style="text-align:center;padding-left:2px;" type="text" maxlength="2" class="input_3_table removespacing" name="everyxvalue" id="everyxvalue" value="3" onkeypress="return validator.isNumber(this,event)" onkeyup="Validate_ScheduleValue(this)" onblur="Validate_ScheduleValue(this)" />
&nbsp;<select name="everyxselect" id="everyxselect" class="input_option" onchange="EveryXToggle(this)">
<option value="hours">hours</option><option value="minutes" selected>minutes</option></select>
<span id="spanxhours" style="color:#FFCC00;"> (between 1 and 24)</span>
<span id="spanxminutes" style="color:#FFCC00;"> (between 1 and 30, default: 3)</span>
</div>
<div id="schcustom">
<div class="schedulesettings">
<a class="hintstyle" href="javascript:void(0);" onclick="SettingHint(1);">
<span class="schedulespan">Hours</span>
</a>
<input data-lpignore="true" autocomplete="off" autocapitalize="off" type="text" class="input_25_table" name="connmon_schhours" value="*" onkeyup="Validate_Schedule(this,'hours')" onblur="Validate_Schedule(this,'hours')" />
<input id="btnfixhours" type="button" onclick="FixCron('hours');" value="Fix?" class="button_gen cronbutton" name="button" style="display:none;">
</div>
<div class="schedulesettings">
<a class="hintstyle" href="javascript:void(0);" onclick="SettingHint(2);">
<span class="schedulespan">Minutes</span>
</a>
<input data-lpignore="true" autocomplete="off" autocapitalize="off" type="text" class="input_25_table" name="connmon_schmins" value="*" onkeyup="Validate_Schedule(this,'mins')" onblur="Validate_Schedule(this,'mins')" />
<input id="btnfixmins" type="button" onclick="FixCron('mins');" value="Fix?" class="button_gen cronbutton" name="button" style="display:none;">
</div>
</div>
</td>
</tr>
<tr class="even" id="rowtimeoutput">
<td class="settingname">Time Output Mode<br/><span class="settingname">(for CSV export)</span></td>
<td class="settingvalue">
<input type="radio" name="connmon_outputtimemode" id="connmon_timeoutput_non-unix" class="input" value="non-unix" checked>
<label for="connmon_timeoutput_non-unix">Non-Unix</label>
<input type="radio" name="connmon_outputtimemode" id="connmon_timeoutput_unix" class="input" value="unix">
<label for="connmon_timeoutput_unix">Unix</label>
</td>
</tr>
<tr class="even" id="rowstorageloc">
<td class="settingname">Data Storage Location</td>
<td class="settingvalue">
<input type="radio" name="connmon_storagelocation" id="connmon_storageloc_jffs" class="input" value="jffs" checked>
<label for="connmon_storageloc_jffs">JFFS</label>
<input type="radio" name="connmon_storagelocation" id="connmon_storageloc_usb" class="input" value="usb">
<label for="connmon_storageloc_usb">USB</label>
</td>
</tr>
<tr class="apply_gen" valign="top" height="35px">
<td colspan="2" class="savebutton">
<input type="button" onclick="SaveConfig();" value="Save" class="button_gen savebutton" name="button">
</td>
</tr>
</table>

<!-- Insert last X results here -->

<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="table_charts">
<thead class="collapsible-jquery" id="thead_charts">
<tr>
<td>Charts (click to expand/collapse)</td>
</tr>
</thead>
<tr><td align="center" style="padding: 0px;">
<table width="100%" border="1" align="center" cellpadding="2" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:0px;" id="table_buttons2">
<thead class="collapsible-jquery" id="charttools">
<tr><td colspan="2">Chart Display Options (click to expand/collapse)</td></tr>
</thead>
<tr>
<th width="20%"><span style="color:#FFFFFF;background:#2F3A3E;">Time format</span><br /><span style="color:#FFCC00;background:#2F3A3E;">(for tooltips and Last 24h chart axis)</span></th>
<td>
<select style="width:100px" class="input_option" onchange="changeAllCharts(this)" id="Time_Format">
<option value="0">24h</option>
<option value="1">12h</option>
</select>
</td>
</tr>
<tr class="apply_gen" valign="top">
<td style="background-color:rgb(77,89,93);" colspan="2">
<input type="button" onclick="ToggleDragZoom(this);" value="Drag Zoom On" class="button_gen" name="btnDragZoom">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" onclick="ResetZoom();" value="Reset Zoom" class="button_gen" name="btnResetZoom">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" onclick="ToggleLines();" value="Toggle Lines" class="button_gen" name="btnToggleLines">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" onclick="ToggleFill();" value="Toggle Fill" class="button_gen" name="btnToggleFill">
</td>
</tr>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
<thead class="collapsible-jquery" id="chart_ping">
<tr>
<td colspan="2">Ping (click to expand/collapse)</td>
</tr>
</thead>
<tr class="even">
<th width="40%">Data interval</th>
<td>
<select style="width:150px" class="input_option" onchange="changeChart(this);changePeriod(this);" id="Ping_Interval">
<option value="0">Raw</option>
<option value="1">Hours</option>
<option value="2">Days</option>
</select>
</td>
</tr>
<tr class="even">
<th width="40%">Period to display</th>
<td>
<select style="width:150px" class="input_option" onchange="changeChart(this)" id="Ping_Period">
<option value="0">Last 24 hours</option>
<option value="1">Last 7 days</option>
<option value="2">Last 30 days</option>
</select>
</td>
</tr>
<tr class="even">
<th width="40%">Scale type</th>
<td>
<select style="width:150px" class="input_option" onchange="changeChart(this)" id="Ping_Scale">
<option value="0">Linear</option>
<option value="1">Logarithmic</option>
</select>
</td>
</tr>
<tr>
<td colspan="2" align="center" style="padding: 0px;">
<div style="background-color:#2f3e44;border-radius:10px;width:730px;height:500px;padding-left:5px;"><canvas id="divLineChart_Ping" height="500" /></div>
</td>
</tr>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
<thead class="collapsible-jquery" id="chart_jitter">
<tr>
<td colspan="2">Jitter (click to expand/collapse)</td>
</tr>
</thead>
<tr class="even">
<th width="40%">Data interval</th>
<td>
<select style="width:150px" class="input_option" onchange="changeChart(this);changePeriod(this);" id="Jitter_Interval">
<option value="0">Raw</option>
<option value="1">Hours</option>
<option value="2">Days</option>
</select>
</td>
</tr>
<tr class="even">
<th width="40%">Period to display</th>
<td>
<select style="width:150px" class="input_option" onchange="changeChart(this)" id="Jitter_Period">
<option value="0">Last 24 hours</option>
<option value="1">Last 7 days</option>
<option value="2">Last 30 days</option>
</select>
</td>
</tr>
<tr class="even">
<th width="40%">Scale type</th>
<td>
<select style="width:150px" class="input_option" onchange="changeChart(this)" id="Jitter_Scale">
<option value="0">Linear</option>
<option value="1">Logarithmic</option>
</select>
</td>
</tr>
<tr>
<td colspan="2" align="center" style="padding: 0px;">
<div style="background-color:#2f3e44;border-radius:10px;width:730px;height:500px;padding-left:5px;"><canvas id="divLineChart_Jitter" height="500" /></div>
</td>
</tr>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
<thead class="collapsible-jquery" id="chart_linequality">
<tr>
<td colspan="2">Quality (click to expand/collapse)</td>
</tr>
</thead>
<tr class="even">
<th width="40%">Data interval</th>
<td>
<select style="width:150px" class="input_option" onchange="changeChart(this);changePeriod(this);" id="LineQuality_Interval">
<option value="0">Raw</option>
<option value="1">Hours</option>
<option value="2">Days</option>
</select>
</td>
</tr>
<tr class="even">
<th width="40%">Period to display</th>
<td>
<select style="width:150px" class="input_option" onchange="changeChart(this)" id="LineQuality_Period">
<option value="0">Last 24 hours</option>
<option value="1">Last 7 days</option>
<option value="2">Last 30 days</option>
</select>
</td>
</tr>
<tr class="even">
<th width="40%">Scale type</th>
<td>
<select style="width:150px" class="input_option" onchange="changeChart(this)" id="LineQuality_Scale">
<option value="0">Linear</option>
<option value="1">Logarithmic</option>
</select>
</td>
</tr>
<tr>
<td colspan="2" align="center" style="padding: 0px;">
<div style="background-color:#2f3e44;border-radius:10px;width:730px;height:500px;padding-left:5px;"><canvas id="divLineChart_LineQuality" height="500" /></div>
</td>
</tr>
</table>
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
<form method="post" name="formScriptActions" action="/start_apply.htm" target="hidden_frame">
<input type="hidden" name="productid" value="<% nvram_get("productid"); %>">
<input type="hidden" name="current_page" value="">
<input type="hidden" name="next_page" value="">
<input type="hidden" name="action_mode" value="apply">
<input type="hidden" name="action_script" value="">
<input type="hidden" name="action_wait" value="">
</form>
<div id="footer"></div>
</body>
</html>
