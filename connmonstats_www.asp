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

thead.collapsible {
  color: white;
  padding: 0px;
  width: 100%;
  border: none;
  text-align: left;
  outline: none;
  cursor: pointer;
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
<script language="JavaScript" type="text/javascript" src="/ext/connmon/connstatstext.js"></script>
<script>
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
var $j=jQuery.noConflict(),maxNoCharts=9,currentNoCharts=0,ShowLines=GetCookie("ShowLines","string"),ShowFill=GetCookie("ShowFill","string");""==ShowFill&&(ShowFill="origin");var DragZoom=!0,ChartPan=!1;Chart.defaults.global.defaultFontColor="#CCC",Chart.Tooltip.positioners.cursor=function(a,b){return b};var metriclist=["Ping","Jitter","PacketLoss"],titlelist=["Ping","Jitter","Quality"],measureunitlist=["ms","ms","%"],chartlist=["daily","weekly","monthly"],timeunitlist=["hour","day","day"],intervallist=[24,7,30],bordercolourlist=["#fc8500","#42ecf5","#ffffff"],backgroundcolourlist=["rgba(252,133,0,0.5)","rgba(66,236,245,0.5)","rgba(255,255,255,0.5)"];function keyHandler(a){27==a.keyCode&&($j(document).off("keydown"),ResetZoom())}$j(document).keydown(function(a){keyHandler(a)}),$j(document).keyup(function(){$j(document).keydown(function(a){keyHandler(a)})});function Validate_IP(a){var b=a.value,c=a.name;return /^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test(b)?($j(a).removeClass("invalid"),!0):($j(a).addClass("invalid"),!1)}function Validate_Domain(a){var b=a.value,c=a.name;return /^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$/.test(b)?($j(a).removeClass("invalid"),!0):($j(a).addClass("invalid"),!1)}function Validate_All(){var a=!1;return Validate_IP(document.form.connmon_ipaddr)||(a=!0),Validate_Domain(document.form.connmon_domain)||(a=!0),!a||(alert("Validation for some fields failed. Please correct invalid values and try again."),!1)}function changePingType(a){var b=a.value,c=a.name;"0"==b?(document.getElementById("rowip").style.display="",document.getElementById("rowdomain").style.display="none"):(document.getElementById("rowip").style.display="none",document.getElementById("rowdomain").style.display="")}function Draw_Chart_NoData(a){document.getElementById("divLineChart_"+a).width="730",document.getElementById("divLineChart_"+a).height="500",document.getElementById("divLineChart_"+a).style.width="730px",document.getElementById("divLineChart_"+a).style.height="500px";var b=document.getElementById("divLineChart_"+a).getContext("2d");b.save(),b.textAlign="center",b.textBaseline="middle",b.font="normal normal bolder 48px Arial",b.fillStyle="white",b.fillText("No data to display",365,250),b.restore()}function Draw_Chart(a,b,c,d,e){var f=getChartPeriod($j("#"+a+"_Period option:selected").val()),g=timeunitlist[$j("#"+a+"_Period option:selected").val()],h=intervallist[$j("#"+a+"_Period option:selected").val()],j=window[a+f];if("undefined"==typeof j||null===j)return void Draw_Chart_NoData(a);if(0==j.length)return void Draw_Chart_NoData(a);var k=j.map(function(a){return a.Metric}),l=j.map(function(a){return{x:a.Time,y:a.Value}}),m=window["LineChart_"+a],n=getTimeFormat($j("#Time_Format option:selected").val(),"axis"),o=getTimeFormat($j("#Time_Format option:selected").val(),"tooltip");factor=0,"hour"==g?factor=3600000:"day"==g&&(factor=86400000),m!=null&&m.destroy();var p=document.getElementById("divLineChart_"+a).getContext("2d"),q={segmentShowStroke:!1,segmentStrokeColor:"#000",animationEasing:"easeOutQuart",animationSteps:100,maintainAspectRatio:!1,animateScale:!0,hover:{mode:"point"},legend:{display:!1,position:"bottom",onClick:null},title:{display:!0,text:b},tooltips:{callbacks:{title:function(a){return moment(a[0].xLabel,"X").format(o)},label:function(a,b){return round(b.datasets[a.datasetIndex].data[a.index].y,3).toFixed(3)+" "+c}},mode:"x",position:"nearest",intersect:!1},scales:{xAxes:[{type:"time",gridLines:{display:!0,color:"#282828"},ticks:{min:moment().subtract(h,g+"s"),display:!0},time:{parser:"X",unit:g,stepSize:1,displayFormats:n}}],yAxes:[{gridLines:{display:!1,color:"#282828"},scaleLabel:{display:!1,labelString:b},ticks:{display:!0,beginAtZero:!0,callback:function(a){return round(a,3).toFixed(3)+" "+c}}}]},plugins:{zoom:{pan:{enabled:ChartPan,mode:"xy",rangeMin:{x:new Date().getTime()-factor*h,y:0},rangeMax:{x:new Date().getTime(),y:getLimit(l,"y","max",!1)+.1*getLimit(l,"y","max",!1)}},zoom:{enabled:!0,drag:DragZoom,mode:"xy",rangeMin:{x:new Date().getTime()-factor*h,y:0},rangeMax:{x:new Date().getTime(),y:getLimit(l,"y","max",!1)+.1*getLimit(l,"y","max",!1)},speed:.1}}},annotation:{drawTime:"afterDatasetsDraw",annotations:[{type:ShowLines,mode:"horizontal",scaleID:"y-axis-0",value:getAverage(l),borderColor:d,borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"center",enabled:!0,xAdjust:0,yAdjust:0,content:"Avg="+round(getAverage(l),3).toFixed(3)+c}},{type:ShowLines,mode:"horizontal",scaleID:"y-axis-0",value:getLimit(l,"y","max",!0),borderColor:d,borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"right",enabled:!0,xAdjust:15,yAdjust:0,content:"Max="+round(getLimit(l,"y","max",!0),3).toFixed(3)+c}},{type:ShowLines,mode:"horizontal",scaleID:"y-axis-0",value:getLimit(l,"y","min",!0),borderColor:d,borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"left",enabled:!0,xAdjust:15,yAdjust:0,content:"Min="+round(getLimit(l,"y","min",!0),3).toFixed(3)+c}}]}},r={labels:k,datasets:[{data:l,borderWidth:1,pointRadius:1,lineTension:0,fill:ShowFill,backgroundColor:e,borderColor:d}]};m=new Chart(p,{type:"line",options:q,data:r}),window["LineChart_"+a]=m}function getLimit(a,b,c,d){var e,f=0;return e="x"==b?a.map(function(a){return a.x}):a.map(function(a){return a.y}),f="max"==c?Math.max.apply(Math,e):Math.min.apply(Math,e),"max"==c&&0==f&&!1==d&&(f=1),f}function getAverage(a){for(var b=0,c=0;c<a.length;c++)b+=1*a[c].y;var d=b/a.length;return d}function round(a,b){return+(Math.round(a+"e"+b)+"e-"+b)}function ToggleLines(){for(""==ShowLines?(ShowLines="line",SetCookie("ShowLines","line")):(ShowLines="",SetCookie("ShowLines","")),i=0;i<metriclist.length;i++){for(i3=0;3>i3;i3++)window["LineChart_"+metriclist[i]].options.annotation.annotations[i3].type=ShowLines;window["LineChart_"+metriclist[i]].update()}}function ToggleFill(){for("false"==ShowFill?(ShowFill="origin",SetCookie("ShowFill","origin")):(ShowFill="false",SetCookie("ShowFill","false")),i=0;i<metriclist.length;i++)window["LineChart_"+metriclist[i]].data.datasets[0].fill=ShowFill,window["LineChart_"+metriclist[i]].update()}function RedrawAllCharts(){for(i=0;i<metriclist.length;i++)for(i2=0;i2<chartlist.length;i2++)d3.csv("/ext/connmon/csv/"+metriclist[i].replace("PacketLoss","Packet_Loss")+chartlist[i2]+".htm").then(SetGlobalDataset.bind(null,metriclist[i]+chartlist[i2]))}function SetGlobalDataset(a,b){if(window[a]=b,currentNoCharts++,currentNoCharts==maxNoCharts)for(i=0;i<metriclist.length;i++)$j("#"+metriclist[i]+"_Period").val(GetCookie(metriclist[i]+"_Period","number")),Draw_Chart(metriclist[i],titlelist[i],measureunitlist[i],bordercolourlist[i],backgroundcolourlist[i])}function getTimeFormat(a,b){var c;return"axis"==b?0==a?c={millisecond:"HH:mm:ss.SSS",second:"HH:mm:ss",minute:"HH:mm",hour:"HH:mm"}:1==a&&(c={millisecond:"h:mm:ss.SSS A",second:"h:mm:ss A",minute:"h:mm A",hour:"h A"}):"tooltip"==b&&(0==a?c="YYYY-MM-DD HH:mm:ss":1==a&&(c="YYYY-MM-DD h:mm:ss A")),c}function GetCookie(a,b){var c;if(null!=(c=cookie.get("conn_"+a)))return cookie.get("conn_"+a);return"string"==b?"":"number"==b?0:void 0}function SetCookie(a,b){cookie.set("conn_"+a,b,31)}function AddEventHandlers(){$j(".collapsible-jquery").click(function(){$j(this).siblings().toggle("fast",function(){"none"==$j(this).css("display")?SetCookie($j(this).siblings()[0].id,"collapsed"):SetCookie($j(this).siblings()[0].id,"expanded")})}),$j(".collapsible-jquery").each(function(){"collapsed"==GetCookie($j(this)[0].id,"string")?$j(this).siblings().toggle(!1):$j(this).siblings().toggle(!0)})}$j.fn.serializeObject=function(){var b=custom_settings,c=this.serializeArray();return $j.each(c,function(){void 0!==b[this.name]&&-1!=this.name.indexOf("connmon")&&-1==this.name.indexOf("version")&&-1==this.name.indexOf("ipaddr")&&-1==this.name.indexOf("domain")?(!b[this.name].push&&(b[this.name]=[b[this.name]]),b[this.name].push(this.value||"")):-1!=this.name.indexOf("connmon")&&-1==this.name.indexOf("version")&&-1==this.name.indexOf("ipaddr")&&-1==this.name.indexOf("domain")&&(b[this.name]=this.value||"")}),b};function SetCurrentPage(){document.form.next_page.value=window.location.pathname.substring(1),document.form.current_page.value=window.location.pathname.substring(1)}function initial(){SetCurrentPage(),LoadCustomSettings(),show_menu(),get_conf_file(),$j("#Time_Format").val(GetCookie("Time_Format","number")),RedrawAllCharts(),ScriptUpdateLayout(),SetConnmonStatsTitle(),AddEventHandlers()}function ScriptUpdateLayout(){var a=GetVersionNumber("local"),b=GetVersionNumber("server");$j("#scripttitle").text($j("#scripttitle").text()+" - "+a),$j("#connmon_version_local").text(a),a!=b&&"N/A"!=b&&($j("#connmon_version_server").text("Updated version available: "+b),showhide("btnChkUpdate",!1),showhide("connmon_version_server",!0),showhide("btnDoUpdate",!0))}function reload(){location.reload(!0)}function getChartPeriod(a){var b="daily";return 0==a?b="daily":1==a?b="weekly":2==a&&(b="monthly"),b}function ResetZoom(){for(i=0;i<metriclist.length;i++){var a=window["LineChart_"+metriclist[i]];"undefined"!=typeof a&&null!==a&&a.resetZoom()}}function ToggleDragZoom(a){var b=!0,c=!1,d="";for(-1==a.value.indexOf("On")?(b=!0,c=!1,DragZoom=!0,ChartPan=!1,d="Drag Zoom On"):(b=!1,c=!0,DragZoom=!1,ChartPan=!0,d="Drag Zoom Off"),i=0;i<metriclist.length;i++){var e=window["LineChart_"+metriclist[i]];"undefined"!=typeof e&&null!==e&&(e.options.plugins.zoom.zoom.drag=b,e.options.plugins.zoom.pan.enabled=c,a.value=d,e.update())}}function ExportCSV(){return location.href="/ext/connmon/csv/connmondata.zip",0}function update_status(){$j.ajax({url:"/ext/connmon/detect_update.js",dataType:"script",timeout:3e3,error:function(){setTimeout("update_status();",1e3)},success:function(){"InProgress"==updatestatus?setTimeout("update_status();",1e3):(document.getElementById("imgChkUpdate").style.display="none",showhide("connmon_version_server",!0),"None"==updatestatus?($j("#connmon_version_server").text("No update available"),showhide("btnChkUpdate",!0),showhide("btnDoUpdate",!1)):($j("#spdmerlin_version_server").text("Updated version available: "+updatestatus),showhide("btnChkUpdate",!1),showhide("btnDoUpdate",!0)))}})}function CheckUpdate(){showhide("btnChkUpdate",!1),document.formChkVer.action_script.value="start_connmoncheckupdate",document.formChkVer.submit(),document.getElementById("imgChkUpdate").style.display="",setTimeout("update_status();",2e3)}function DoUpdate(){document.form.action_script.value="start_connmondoupdate";document.form.action_wait.value=20,showLoading(),document.form.submit()}function applyRule(){if(Validate_All()){0==document.form.pingtype.value?document.form.connmon_pingserver.value=document.form.connmon_ipaddr.value:1==document.form.pingtype.value&&(document.form.connmon_pingserver.value=document.form.connmon_domain.value),document.getElementById("amng_custom").value=JSON.stringify($j("form").serializeObject());document.form.action_script.value="start_connmonconfig";document.form.action_wait.value=5,showLoading(),document.form.submit()}else return!1}function GetVersionNumber(a){var b;return"local"==a?b=custom_settings.connmon_version_local:"server"==a&&(b=custom_settings.connmon_version_server),"undefined"==typeof b||null==b?"N/A":b}function get_conf_file(){$j.ajax({url:"/ext/connmon/config.htm",dataType:"text",error:function(){setTimeout("get_conf_file();",1e3)},success:function(a){var b=a.split("\n");b=b.filter(Boolean);for(var c=0;c<b.length;c++)if(-1!=b[c].indexOf("PINGSERVER")){var d=b[c].split("=")[1].replace(/(\r\n|\n|\r)/gm,"");document.form.connmon_pingserver.value=d,Validate_IP(document.form.connmon_pingserver)?(document.form.pingtype.value=0,document.form.connmon_ipaddr.value=d):(document.form.pingtype.value=1,document.form.connmon_domain.value=d),document.form.pingtype.onchange()}else-1==b[c].indexOf("OUTPUTDATAMODE")?-1==b[c].indexOf("OUTPUTTIMEMODE")?-1!=b[c].indexOf("STORAGELOCATION")&&(document.form.connmon_storagelocation.value=b[c].split("=")[1].replace(/(\r\n|\n|\r)/gm,"")):document.form.connmon_outputtimemode.value=b[c].split("=")[1].replace(/(\r\n|\n|\r)/gm,""):document.form.connmon_outputdatamode.value=b[c].split("=")[1].replace(/(\r\n|\n|\r)/gm,"")}})}function runPingTest(){document.form.action_script.value="start_connmon";document.form.action_wait.value=70,showLoading(),document.form.submit()}function changeAllCharts(a){for(value=1*a.value,name=a.id.substring(0,a.id.indexOf("_")),SetCookie(a.id,value),i=0;i<metriclist.length;i++)Draw_Chart(metriclist[i],titlelist[i],measureunitlist[i],bordercolourlist[i],backgroundcolourlist[i])}function changeChart(a){value=1*a.value,name=a.id.substring(0,a.id.indexOf("_")),SetCookie(a.id,value),"Ping"==name?Draw_Chart("Ping",titlelist[0],measureunitlist[0],bordercolourlist[0],backgroundcolourlist[0]):"Jitter"==name?Draw_Chart("Jitter",titlelist[1],measureunitlist[1],bordercolourlist[1],backgroundcolourlist[1]):"PacketLoss"==name&&Draw_Chart("PacketLoss",titlelist[2],measureunitlist[2],bordercolourlist[2],backgroundcolourlist[2])}
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
<div class="collapsiblecontent">
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
<th width="20%">Update stats</th>
<td>
<input type="button" onclick="runPingTest();" value="Run ping test" class="button_gen" name="btnRunPingtest">
</td>
</tr>
<tr>
<th width="20%">Export</th>
<td>
<input type="button" onclick="ExportCSV();" value="Export to CSV" class="button_gen" name="btnExport">
</td>
</tr>
</div>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="2" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:0px;" id="table_config">
<thead class="collapsible-jquery" id="scriptconfig">
<tr><td colspan="2">Configuration (click to expand/collapse)</td></tr>
</thead>
<div class="collapsiblecontent">
<tr class="even">
<th width="40%">Ping destination type</th>
<td>
<select style="width:125px" class="input_option" onchange="changePingType(this)" id="pingtype">
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
<tr class="even" id="rowdataoutput">
<th width="40%">Data Output Mode</th>
<td class="settingvalue">
<input autocomplete="off" autocapitalize="off" type="radio" name="connmon_outputdatamode" id="connmon_dataoutput_average" class="input" value="average" checked>Average
<input autocomplete="off" autocapitalize="off" type="radio" name="connmon_outputdatamode" id="connmon_dataoutput_raw" class="input" value="raw">Raw
</td>
</tr>
<tr class="even" id="rowtimeoutput">
<th width="40%">Time Output Mode</th>
<td class="settingvalue">
<input autocomplete="off" autocapitalize="off" type="radio" name="connmon_outputtimemode" id="connmon_timeoutput_non-unix" class="input" value="non-unix" checked>Non-Unix
<input autocomplete="off" autocapitalize="off" type="radio" name="connmon_outputtimemode" id="connmon_timeoutput_unix" class="input" value="unix">Unix
</td>
</tr>
<tr class="even" id="rowstorageloc">
<th width="40%">Data Storage Location</th>
<td class="settingvalue">
<input autocomplete="off" autocapitalize="off" type="radio" name="connmon_storagelocation" id="connmon_storageloc_jffs" class="input" value="jffs" checked>JFFS
<input autocomplete="off" autocapitalize="off" type="radio" name="connmon_storagelocation" id="connmon_storageloc_usb" class="input" value="usb">USB
</td>
</tr>
<tr class="apply_gen" valign="top" height="35px">
<td colspan="2" style="background-color:rgb(77, 89, 93);">
<input type="button" onclick="applyRule();" value="Save" class="button_gen" name="button">
</td>
</tr>
</div>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="2" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:0px;" id="table_buttons2">
<thead class="collapsible-jquery" id="charttools">
<tr><td colspan="2">Chart Display Options (click to expand/collapse)</td></tr>
</thead>
<div class="collapsiblecontent">
<tr>
<th width="20%"><span style="color:#FFFFFF;">Time format</span><br /><span style="color:#FFFFFF;">for tooltips and Last 24h chart axis</span></th>
<td>
<select style="width:100px" class="input_option" onchange="changeAllCharts(this)" id="Time_Format">
<option value="0">24h</option>
<option value="1">12h</option>
</select>
</td>
</tr>
<tr class="apply_gen" valign="top">
<td style="background-color:rgb(77, 89, 93);" colspan="2">
<input type="button" onclick="ToggleDragZoom(this);" value="Drag Zoom On" class="button_gen" name="btnDragZoom">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" onclick="ResetZoom();" value="Reset Zoom" class="button_gen" name="btnResetZoom">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" onclick="ToggleLines();" value="Toggle Lines" class="button_gen" name="btnToggleLines">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" onclick="ToggleFill();" value="Toggle Fill" class="button_gen" name="btnToggleFill">
</td>
</tr>
</div>
</table>
<div style="line-height:10px;">&nbsp;</div>

<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
<thead class="collapsible-jquery" id="table_charts">
<tr>
<td>Charts (click to expand/collapse)</td>
</tr>
</thead>
<div class="collapsiblecontent">
<tr><td align="center" style="padding: 0px;">
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
<thead class="collapsible-jquery" id="chart_ping">
<tr>
<td colspan="2">Ping (click to expand/collapse)</td>
</tr>
</thead>
<div class="collapsiblecontent">
<tr class="even">
<th width="40%">Period to display</th>
<td>
<select style="width:125px" class="input_option" onchange="changeChart(this)" id="Ping_Period">
<option value="0">Last 24 hours</option>
<option value="1">Last 7 days</option>
<option value="2">Last 30 days</option>
</select>
</td>
</tr>
<tr>
<td colspan="2" align="center" style="padding: 0px;">
<div style="background-color:#2f3e44;border-radius:10px;width:730px;height:500px;padding-left:5px;"><canvas id="divLineChart_Ping" height="500" /></div>
</td>
</tr>
</div>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
<thead class="collapsible-jquery" id="chart_jitter">
<tr>
<td colspan="2">Jitter (click to expand/collapse)</td>
</tr>
</thead>
<div class="collapsiblecontent">
<tr class="even">
<th width="40%">Period to display</th>
<td>
<select style="width:125px" class="input_option" onchange="changeChart(this)" id="Jitter_Period">
<option value="0">Last 24 hours</option>
<option value="1">Last 7 days</option>
<option value="2">Last 30 days</option>
</select>
</td>
</tr>
<tr>
<td colspan="2" align="center" style="padding: 0px;">
<div style="background-color:#2f3e44;border-radius:10px;width:730px;height:500px;padding-left:5px;"><canvas id="divLineChart_Jitter" height="500" /></div>
</td>
</tr>
</div>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
<thead class="collapsible-jquery" id="chart_packetloss">
<tr>
<td colspan="2">Quality (click to expand/collapse)</td>
</tr>
</thead>
<div class="collapsiblecontent">
<tr class="even">
<th width="40%">Period to display</th>
<td>
<select style="width:125px" class="input_option" onchange="changeChart(this)" id="PacketLoss_Period">
<option value="0">Last 24 hours</option>
<option value="1">Last 7 days</option>
<option value="2">Last 30 days</option>
</select>
</td>
</tr>
<tr>
<td colspan="2" align="center" style="padding: 0px;">
<div style="background-color:#2f3e44;border-radius:10px;width:730px;height:500px;padding-left:5px;"><canvas id="divLineChart_PacketLoss" height="500" /></div>
</td>
</tr>
</div>
</table>
</td>
</tr>
</div>
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
<form method="post" name="formChkVer" action="/start_apply.htm" target="hidden_frame">
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
