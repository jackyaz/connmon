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

input.settingvalue {
  margin-left: 3px !important;
}

label.settingvalue {
  margin-right: 10px !important;
  vertical-align: top !important;
}

.invalid {
  background-color: darkred !important;
}

.removespacing {
  padding-left: 0px !important;
  margin-left: 0px !important;
  margin-bottom: 5px !important;
  text-align: center !important;
}

.schedulespan {
  display:inline-block !important;
  width:60px !important;
  color:#FFFFFF !important;
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
	for (var prop in custom_settings) {
		if (Object.prototype.hasOwnProperty.call(custom_settings, prop)) {
			if(prop.indexOf("connmon") != -1 && prop.indexOf("connmon_version") == -1){
				eval("delete custom_settings."+prop)
			}
		}
	}
}
var $j=jQuery.noConflict(),pingtestdur=60,maxNoCharts=9,currentNoCharts=0,ShowLines=GetCookie("ShowLines","string"),ShowFill=GetCookie("ShowFill","string");""==ShowFill&&(ShowFill="origin");var DragZoom=!0,ChartPan=!1;Chart.defaults.global.defaultFontColor="#CCC",Chart.Tooltip.positioners.cursor=function(a,b){return b};var metriclist=["Ping","Jitter","LineQuality"],titlelist=["Ping","Jitter","Quality"],measureunitlist=["ms","ms","%"],chartlist=["daily","weekly","monthly"],timeunitlist=["hour","day","day"],intervallist=[24,7,30],bordercolourlist=["#fc8500","#42ecf5","#ffffff"],backgroundcolourlist=["rgba(252,133,0,0.5)","rgba(66,236,245,0.5)","rgba(255,255,255,0.5)"];function keyHandler(a){27==a.keyCode&&($j(document).off("keydown"),ResetZoom())}$j(document).keydown(function(a){keyHandler(a)}),$j(document).keyup(function(){$j(document).keydown(function(a){keyHandler(a)})});function Validate_IP(a){var b=a.value,c=a.name;return /^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test(b)?($j(a).removeClass("invalid"),!0):($j(a).addClass("invalid"),!1)}function Validate_Domain(a){var b=a.value,c=a.name;return /^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$/.test(b)?($j(a).removeClass("invalid"),!0):($j(a).addClass("invalid"),!1)}function Validate_PingDuration(a){var b=a.name,c=1*a.value;return 60<c||10>c?($j(a).addClass("invalid"),!1):($j(a).removeClass("invalid"),!0)}function Validate_PingFrequency(a){var b=a.name,c=1*a.value;return 10<c||1>c?($j(a).addClass("invalid"),!1):($j(a).removeClass("invalid"),!0)}function Validate_ScheduleRange(a){var b=a.name,c=1*a.value;return 23<c||0>c||1>a.value.length?($j(a).addClass("invalid"),!1):($j(a).removeClass("invalid"),!0)}function Validate_All(){var a=!1;return Validate_IP(document.form.connmon_ipaddr)||(a=!0),Validate_Domain(document.form.connmon_domain)||(a=!0),Validate_PingDuration(document.form.connmon_pingduration)||(a=!0),Validate_PingFrequency(document.form.connmon_pingfrequency)||(a=!0),Validate_ScheduleRange(document.form.connmon_schedulestart)||(a=!0),Validate_ScheduleRange(document.form.connmon_scheduleend)||(a=!0),!a||(alert("Validation for some fields failed. Please correct invalid values and try again."),!1)}function changePingType(a){var b=a.value,c=a.name;"0"==b?(document.getElementById("rowip").style.display="",document.getElementById("rowdomain").style.display="none"):(document.getElementById("rowip").style.display="none",document.getElementById("rowdomain").style.display="")}function Draw_Chart_NoData(a){document.getElementById("divLineChart_"+a).width="730",document.getElementById("divLineChart_"+a).height="500",document.getElementById("divLineChart_"+a).style.width="730px",document.getElementById("divLineChart_"+a).style.height="500px";var b=document.getElementById("divLineChart_"+a).getContext("2d");b.save(),b.textAlign="center",b.textBaseline="middle",b.font="normal normal bolder 48px Arial",b.fillStyle="white",b.fillText("No data to display",365,250),b.restore()}function Draw_Chart(a,b,c,d,e){var f=getChartPeriod($j("#"+a+"_Period option:selected").val()),g=timeunitlist[$j("#"+a+"_Period option:selected").val()],h=intervallist[$j("#"+a+"_Period option:selected").val()],j=window[a+f];if("undefined"==typeof j||null===j)return void Draw_Chart_NoData(a);if(0==j.length)return void Draw_Chart_NoData(a);var k=j.map(function(a){return a.Metric}),l=j.map(function(a){return{x:a.Time,y:a.Value}}),m=window["LineChart_"+a],n=getTimeFormat($j("#Time_Format option:selected").val(),"axis"),o=getTimeFormat($j("#Time_Format option:selected").val(),"tooltip");factor=0,"hour"==g?factor=3600000:"day"==g&&(factor=86400000),m!=null&&m.destroy();var p=document.getElementById("divLineChart_"+a).getContext("2d"),q={segmentShowStroke:!1,segmentStrokeColor:"#000",animationEasing:"easeOutQuart",animationSteps:100,maintainAspectRatio:!1,animateScale:!0,hover:{mode:"point"},legend:{display:!1,position:"bottom",onClick:null},title:{display:!0,text:b},tooltips:{callbacks:{title:function(a){return moment(a[0].xLabel,"X").format(o)},label:function(a,b){return round(b.datasets[a.datasetIndex].data[a.index].y,2).toFixed(2)+" "+c}},mode:"point",position:"cursor",intersect:!0},scales:{xAxes:[{type:"time",gridLines:{display:!0,color:"#282828"},ticks:{min:moment().subtract(h,g+"s"),display:!0},time:{parser:"X",unit:g,stepSize:1,displayFormats:n}}],yAxes:[{type:getChartScale($j("#"+a+"_Scale option:selected").val()),gridLines:{display:!1,color:"#282828"},scaleLabel:{display:!1,labelString:c},ticks:{display:!0,beginAtZero:!0,max:getYAxisMax(a),labels:{index:["min","max"],removeEmptyLines:!0},userCallback:LogarithmicFormatter}}]},plugins:{zoom:{pan:{enabled:ChartPan,mode:"xy",rangeMin:{x:new Date().getTime()-factor*h,y:0},rangeMax:{x:new Date().getTime(),y:getLimit(l,"y","max",!1)+.1*getLimit(l,"y","max",!1)}},zoom:{enabled:!0,drag:DragZoom,mode:"xy",rangeMin:{x:new Date().getTime()-factor*h,y:0},rangeMax:{x:new Date().getTime(),y:getLimit(l,"y","max",!1)+.1*getLimit(l,"y","max",!1)},speed:.1}}},annotation:{drawTime:"afterDatasetsDraw",annotations:[{type:ShowLines,mode:"horizontal",scaleID:"y-axis-0",value:getAverage(l),borderColor:d,borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"center",enabled:!0,xAdjust:0,yAdjust:0,content:"Avg="+round(getAverage(l),2).toFixed(2)+c}},{type:ShowLines,mode:"horizontal",scaleID:"y-axis-0",value:getLimit(l,"y","max",!0),borderColor:d,borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"right",enabled:!0,xAdjust:15,yAdjust:0,content:"Max="+round(getLimit(l,"y","max",!0),2).toFixed(2)+c}},{type:ShowLines,mode:"horizontal",scaleID:"y-axis-0",value:getLimit(l,"y","min",!0),borderColor:d,borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"left",enabled:!0,xAdjust:15,yAdjust:0,content:"Min="+round(getLimit(l,"y","min",!0),2).toFixed(2)+c}}]}},r={labels:k,datasets:[{data:l,borderWidth:1,pointRadius:1,lineTension:0,fill:ShowFill,backgroundColor:e,borderColor:d}]};m=new Chart(p,{type:"line",options:q,data:r}),window["LineChart_"+a]=m}function LogarithmicFormatter(a,b,c){var d=this.options.scaleLabel.labelString;if("logarithmic"!=this.type)return isNaN(a)?a+" "+d:round(a,2).toFixed(2)+" "+d;var e=this.options.ticks.labels||{},f=e.index||["min","max"],g=e.significand||[1,2,5],h=a/Math.pow(10,Math.floor(Chart.helpers.log10(a))),j=!0===e.removeEmptyLines?void 0:"",k="";return 0===b?k="min":b==c.length-1&&(k="max"),"all"===e||-1!==g.indexOf(h)||-1!==f.indexOf(b)||-1!==f.indexOf(k)?0===a?"0 "+d:isNaN(a)?a+" "+d:round(a,2).toFixed(2)+" "+d:j}function getLimit(a,b,c,d){var e,f=0;return e="x"==b?a.map(function(a){return a.x}):a.map(function(a){return a.y}),f="max"==c?Math.max.apply(Math,e):Math.min.apply(Math,e),"max"==c&&0==f&&!1==d&&(f=1),f}function getYAxisMax(a){if("LineQuality"==a)return 100}function getAverage(a){for(var b=0,c=0;c<a.length;c++)b+=1*a[c].y;var d=b/a.length;return d}function round(a,b){return+(Math.round(a+"e"+b)+"e-"+b)}function ToggleLines(){for(""==ShowLines?(ShowLines="line",SetCookie("ShowLines","line")):(ShowLines="",SetCookie("ShowLines","")),i=0;i<metriclist.length;i++){for(i3=0;3>i3;i3++)window["LineChart_"+metriclist[i]].options.annotation.annotations[i3].type=ShowLines;window["LineChart_"+metriclist[i]].update()}}function ToggleFill(){for("false"==ShowFill?(ShowFill="origin",SetCookie("ShowFill","origin")):(ShowFill="false",SetCookie("ShowFill","false")),i=0;i<metriclist.length;i++)window["LineChart_"+metriclist[i]].data.datasets[0].fill=ShowFill,window["LineChart_"+metriclist[i]].update()}function RedrawAllCharts(){for(i=0;i<metriclist.length;i++)for(i2=0;i2<chartlist.length;i2++)d3.csv("/ext/connmon/csv/"+metriclist[i]+chartlist[i2]+".htm").then(SetGlobalDataset.bind(null,metriclist[i]+chartlist[i2]))}function SetGlobalDataset(a,b){if(window[a]=b,currentNoCharts++,currentNoCharts==maxNoCharts){for(showhide("imgConnTest",!1),showhide("conntest_text",!1),showhide("btnRunPingtest",!0),BuildLastXTable(),i=0;i<metriclist.length;i++)$j("#"+metriclist[i]+"_Period").val(GetCookie(metriclist[i]+"_Period","number")),$j("#"+metriclist[i]+"_Scale").val(GetCookie(metriclist[i]+"_Scale","number")),Draw_Chart(metriclist[i],titlelist[i],measureunitlist[i],bordercolourlist[i],backgroundcolourlist[i]);AddEventHandlers()}}function getChartScale(a){var b="";return 0==a?b="linear":1==a&&(b="logarithmic"),b}function getTimeFormat(a,b){var c;return"axis"==b?0==a?c={millisecond:"HH:mm:ss.SSS",second:"HH:mm:ss",minute:"HH:mm",hour:"HH:mm"}:1==a&&(c={millisecond:"h:mm:ss.SSS A",second:"h:mm:ss A",minute:"h:mm A",hour:"h A"}):"tooltip"==b&&(0==a?c="YYYY-MM-DD HH:mm:ss":1==a&&(c="YYYY-MM-DD h:mm:ss A")),c}function GetCookie(a,b){var c;if(null!=(c=cookie.get("conn_"+a)))return cookie.get("conn_"+a);return"string"==b?"":"number"==b?0:void 0}function SetCookie(a,b){cookie.set("conn_"+a,b,31)}function AddEventHandlers(){$j(".collapsible-jquery").click(function(){$j(this).siblings().toggle("fast",function(){"none"==$j(this).css("display")?SetCookie($j(this).siblings()[0].id,"collapsed"):SetCookie($j(this).siblings()[0].id,"expanded")})}),$j(".collapsible-jquery").each(function(){"collapsed"==GetCookie($j(this)[0].id,"string")?$j(this).siblings().toggle(!1):$j(this).siblings().toggle(!0)})}$j.fn.serializeObject=function(){var b=custom_settings,c=this.serializeArray();return $j.each(c,function(){void 0!==b[this.name]&&-1!=this.name.indexOf("connmon")&&-1==this.name.indexOf("version")&&-1==this.name.indexOf("ipaddr")&&-1==this.name.indexOf("domain")?(!b[this.name].push&&(b[this.name]=[b[this.name]]),b[this.name].push(this.value||"")):-1!=this.name.indexOf("connmon")&&-1==this.name.indexOf("version")&&-1==this.name.indexOf("ipaddr")&&-1==this.name.indexOf("domain")&&(b[this.name]=this.value||"")}),b};function SetCurrentPage(){document.form.next_page.value=window.location.pathname.substring(1),document.form.current_page.value=window.location.pathname.substring(1)}function ParseCSVExport(a){for(var b,c="Timestamp,Ping,Jitter,LineQuality\n",d=0;d<a.length;d++)b=a[d].Timestamp+","+a[d].Ping+","+a[d].Jitter+","+a[d].LineQuality,c+=d<a.length-1?b+"\n":b;document.getElementById("aExport").href="data:text/csv;charset=utf-8,"+encodeURIComponent(c)}function ErrorCSVExport(){document.getElementById("aExport").href="javascript:alert(\"Error exporting CSV, please refresh the page and try again\")"}function initial(){SetCurrentPage(),LoadCustomSettings(),show_menu(),get_conf_file(),d3.csv("/ext/connmon/csv/CompleteResults.htm").then(function(a){ParseCSVExport(a)}).catch(function(){ErrorCSVExport()}),$j("#Time_Format").val(GetCookie("Time_Format","number")),RedrawAllCharts(),ScriptUpdateLayout(),SetConnmonStatsTitle()}function ScriptUpdateLayout(){var a=GetVersionNumber("local"),b=GetVersionNumber("server");$j("#scripttitle").text($j("#scripttitle").text()+" - "+a),$j("#connmon_version_local").text(a),a!=b&&"N/A"!=b&&($j("#connmon_version_server").text("Updated version available: "+b),showhide("btnChkUpdate",!1),showhide("connmon_version_server",!0),showhide("btnDoUpdate",!0))}function reload(){location.reload(!0)}function getChartPeriod(a){var b="daily";return 0==a?b="daily":1==a?b="weekly":2==a&&(b="monthly"),b}function ResetZoom(){for(i=0;i<metriclist.length;i++){var a=window["LineChart_"+metriclist[i]];"undefined"!=typeof a&&null!==a&&a.resetZoom()}}function ToggleDragZoom(a){var b=!0,c=!1,d="";for(-1==a.value.indexOf("On")?(b=!0,c=!1,DragZoom=!0,ChartPan=!1,d="Drag Zoom On"):(b=!1,c=!0,DragZoom=!1,ChartPan=!0,d="Drag Zoom Off"),i=0;i<metriclist.length;i++){var e=window["LineChart_"+metriclist[i]];"undefined"!=typeof e&&null!==e&&(e.options.plugins.zoom.zoom.drag=b,e.options.plugins.zoom.pan.enabled=c,a.value=d,e.update())}}function update_status(){$j.ajax({url:"/ext/connmon/detect_update.js",dataType:"script",timeout:3e3,error:function(){setTimeout(update_status,1e3)},success:function(){"InProgress"==updatestatus?setTimeout(update_status,1e3):(document.getElementById("imgChkUpdate").style.display="none",showhide("connmon_version_server",!0),"None"==updatestatus?($j("#connmon_version_server").text("No update available"),showhide("btnChkUpdate",!0),showhide("btnDoUpdate",!1)):($j("#connmon_version_server").text("Updated version available: "+updatestatus),showhide("btnChkUpdate",!1),showhide("btnDoUpdate",!0)))}})}function CheckUpdate(){showhide("btnChkUpdate",!1),document.formScriptActions.action_script.value="start_connmoncheckupdate",document.formScriptActions.submit(),document.getElementById("imgChkUpdate").style.display="",setTimeout(update_status,2e3)}function DoUpdate(){document.form.action_script.value="start_connmondoupdate";document.form.action_wait.value=10,showLoading(),document.form.submit()}function SaveConfig(){if(Validate_All()){0==document.form.pingtype.value?document.form.connmon_pingserver.value=document.form.connmon_ipaddr.value:1==document.form.pingtype.value&&(document.form.connmon_pingserver.value=document.form.connmon_domain.value),document.getElementById("amng_custom").value=JSON.stringify($j("form").serializeObject());document.form.action_script.value="start_connmonconfig";document.form.action_wait.value=5,showLoading(),document.form.submit()}else return!1}function GetVersionNumber(a){var b;return"local"==a?b=custom_settings.connmon_version_local:"server"==a&&(b=custom_settings.connmon_version_server),"undefined"==typeof b||null==b?"N/A":b}function get_conntestresult_file(){$j.ajax({url:"/ext/connmon/ping-result.htm",dataType:"text",timeout:1e3,error:function(){setTimeout(get_conntestresult_file,500)},success:function(a){var b=a.trim().split("\n");a=b.join("\n"),$j("#conntest_output").html(a),document.getElementById("conntest_output").parentElement.parentElement.style.display=""}})}function get_conf_file(){$j.ajax({url:"/ext/connmon/config.htm",dataType:"text",error:function(){setTimeout(get_conf_file,1e3)},success:function(data){var configdata=data.split("\n");configdata=configdata.filter(Boolean);for(var i=0;i<configdata.length;i++)if(-1==configdata[i].indexOf("PINGSERVER")&&(eval("document.form.connmon_"+configdata[i].split("=")[0].toLowerCase()).value=configdata[i].split("=")[1].replace(/(\r\n|\n|\r)/gm,"")),-1!=configdata[i].indexOf("PINGSERVER")){var pingserver=configdata[i].split("=")[1].replace(/(\r\n|\n|\r)/gm,"");document.form.connmon_pingserver.value=pingserver,Validate_IP(document.form.connmon_pingserver)?(document.form.pingtype.value=0,document.form.connmon_ipaddr.value=pingserver):(document.form.pingtype.value=1,document.form.connmon_domain.value=pingserver),document.form.pingtype.onchange()}else-1!=configdata[i].indexOf("PINGDURATION")&&(pingtestdur=document.form.connmon_pingduration.value)}})}var pingcount=2;function update_conntest(){pingcount++,$j.ajax({url:"/ext/connmon/detect_connmon.js",dataType:"script",timeout:1e3,error:function(){},success:function(){"InProgress"==connmonstatus?(showhide("imgConnTest",!0),showhide("conntest_text",!0),document.getElementById("conntest_text").innerHTML="Ping test in progress - "+pingcount+"s elapsed"):"Done"==connmonstatus?(get_conntestresult_file(),document.getElementById("conntest_text").innerHTML="Refreshing charts...",pingcount=2,clearInterval(myinterval),PostConnTest()):"LOCKED"==connmonstatus?(showhide("imgConnTest",!1),document.getElementById("conntest_text").innerHTML="Scheduled ping test already running!",showhide("conntest_text",!0),showhide("btnRunPingtest",!0),document.getElementById("conntest_output").parentElement.parentElement.style.display="none",clearInterval(myinterval)):"InvalidServer"==connmonstatus&&(showhide("imgConnTest",!1),document.getElementById("conntest_text").innerHTML="Specified ping server is not valid",showhide("conntest_text",!0),showhide("btnRunPingtest",!0),document.getElementById("conntest_output").parentElement.parentElement.style.display="none",clearInterval(myinterval))}})}function PostConnTest(){currentNoCharts=0,$j("#resulttable_pings").remove(),reload_js("/ext/connmon/connjs.js"),reload_js("/ext/connmon/connstatstext.js"),$j("#Time_Format").val(GetCookie("Time_Format","number")),SetConnmonStatsTitle(),setTimeout(RedrawAllCharts,3e3)}function runPingTest(){showhide("btnRunPingtest",!1),$j("#conntest_output").html(""),document.getElementById("conntest_output").parentElement.parentElement.style.display="none",document.formScriptActions.action_script.value="start_connmon",document.formScriptActions.submit(),showhide("imgConnTest",!0),showhide("conntest_text",!1),setTimeout(StartConnTestInterval,2e3)}var myinterval;function StartConnTestInterval(){myinterval=setInterval(update_conntest,1e3)}function reload_js(a){$j("script[src=\""+a+"\"]").remove(),$j("<script>").attr("src",a+"?cachebuster="+new Date().getTime()).appendTo("head")}function changeAllCharts(a){for(value=1*a.value,name=a.id.substring(0,a.id.indexOf("_")),SetCookie(a.id,value),i=0;i<metriclist.length;i++)Draw_Chart(metriclist[i],titlelist[i],measureunitlist[i],bordercolourlist[i],backgroundcolourlist[i])}function changeChart(a){value=1*a.value,name=a.id.substring(0,a.id.indexOf("_")),SetCookie(a.id,value),"Ping"==name?Draw_Chart("Ping",titlelist[0],measureunitlist[0],bordercolourlist[0],backgroundcolourlist[0]):"Jitter"==name?Draw_Chart("Jitter",titlelist[1],measureunitlist[1],bordercolourlist[1],backgroundcolourlist[1]):"LineQuality"==name&&Draw_Chart("LineQuality",titlelist[2],measureunitlist[2],bordercolourlist[2],backgroundcolourlist[2])}function BuildLastXTable(){var a="<div style=\"line-height:10px;\">&nbsp;</div>";a+="<table width=\"100%\" border=\"1\" align=\"center\" cellpadding=\"4\" cellspacing=\"0\" bordercolor=\"#6b8fa3\" class=\"FormTable\" id=\"resulttable_pings\">",a+="<thead class=\"collapsible-jquery\" id=\"resultthead_pings\">",a+="<tr><td colspan=\"2\">Last 10 ping test results (click to expand/collapse)</td></tr>",a+="</thead>",a+="<tr>",a+="<td colspan=\"2\" align=\"center\" style=\"padding: 0px;\">",a+="<table width=\"100%\" border=\"1\" align=\"center\" cellpadding=\"4\" cellspacing=\"0\" bordercolor=\"#6b8fa3\" class=\"FormTable StatsTable\">";var b="",c=window.DataTimestamp;if("undefined"==typeof c||null===c?b="true":0==c.length?b="true":1==c.length&&""==c[0]&&(b="true"),"true"==b)a+="<tr>",a+="<td colspan=\"4\" class=\"nodata\">",a+="No data to display",a+="</td>",a+="</tr>";else for(a+="<col style=\"width:185px;\">",a+="<col style=\"width:185px;\">",a+="<col style=\"width:185px;\">",a+="<col style=\"width:185px;\">",a+="<thead>",a+="<tr>",a+="<th class=\"keystatsnumber\">Time</th>",a+="<th class=\"keystatsnumber\">Ping (ms)</th>",a+="<th class=\"keystatsnumber\">Jitter (ms)</th>",a+="<th class=\"keystatsnumber\">Line Quality (%)</th>",a+="</tr>",a+="</thead>",i=0;i<c.length;i++)a+="<tr>",a+="<td>"+moment.unix(window.DataTimestamp[i]).format("YYYY-MM-DD HH:mm:ss")+"</td>",a+="<td>"+window.DataPing[i]+"</td>",a+="<td>"+window.DataJitter[i]+"</td>",a+="<td>"+window.DataLineQuality[i].replace("null","")+"</td>",a+="</tr>";a+="</table>",a+="</td>",a+="</tr>",a+="</table>",$j("#table_buttons2").after(a)}
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
<table width="100%" border="1" align="center" cellpadding="2" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:0px;" id="table_config">
<thead class="collapsible-jquery" id="scriptconfig">
<tr><td colspan="2">Configuration (click to expand/collapse)</td></tr>
</thead>
<tr class="even">
<th width="40%">Ping destination type</th>
<td class="settingvalue">
<select style="width:125px" class="input_option" onchange="changePingType(this)" id="pingtype">
<option value="0">IP Address</option>
<option value="1">Domain</option>
</select>
</td>
</tr>
<tr class="even" id="rowip">
<th width="40%">IP Address</th>
<td class="settingvalue">
<input autocomplete="off" type="text" maxlength="15" class="input_15_table removespacing" name="connmon_ipaddr" value="8.8.8.8" onkeypress="return validator.isIPAddr(this, event)" onblur="Validate_IP(this)" data-lpignore="true" />
</td>
</tr>
<tr class="even" id="rowdomain">
<th width="40%">Domain</th>
<td class="settingvalue">
<input autocorrect="off" autocapitalize="off" type="text" maxlength="255" class="input_32_table removespacing" name="connmon_domain" value="google.co.uk" onkeypress="return validator.isString(this, event);" onblur="Validate_Domain(this)" data-lpignore="true" />
</td>
</tr>
<tr class="even" id="rowpingdur">
<th width="40%">Ping test duration</th>
<td>
<input autocomplete="off" type="text" maxlength="2" class="input_3_table removespacing" name="connmon_pingduration" value="60" onkeypress="return validator.isNumber(this, event)" onblur="Validate_PingDuration(this)" />
seconds <span style="color:#FFCC00;">(between 10 and 60, default: 60)</span>
</td>
</tr>
<tr class="even" id="rowpingfreq">
<th width="40%">Ping test frequency</th>
<td>Every
<input autocomplete="off" type="text" maxlength="2" class="input_3_table removespacing" name="connmon_pingfrequency" value="3" onkeypress="return validator.isNumber(this, event)" onblur="Validate_PingFrequency(this)" />
minutes <span style="color:#FFCC00;">(between 1 and 10, default: 3)</span>
</td>
</tr>
<tr class="even" id="rowschedule">
<th width="40%">Schedule for automatic ping tests</th>
<td class="settingvalue"><span class="schedulespan">Start hour</span>
<input autocomplete="off" type="text" maxlength="2" class="input_3_table removespacing" name="connmon_schedulestart" value="0" onkeypress="return validator.isNumber(this, event)" onkeyup="Validate_ScheduleRange(this)" onblur="Validate_ScheduleRange(this)" />
<span style="color:#FFCC00;">(between 0 and 23, default: 0)</span><br /><span class="schedulespan">End hour</span>
<input autocomplete="off" type="text" maxlength="2" class="input_3_table removespacing" name="connmon_scheduleend" value="23" onkeypress="return validator.isNumber(this, event)" onkeyup="Validate_ScheduleRange(this)" onblur="Validate_ScheduleRange(this)" />
<span style="color:#FFCC00;">(between 0 and 23, default: 23)</span>
</td>
</tr>
<tr class="even" id="rowdataoutput">
<th width="40%">Data Output Mode<br/><span style="color:#FFCC00;">(for weekly and monthly charts)</span></th>
<td class="settingvalue">
<input type="radio" name="connmon_outputdatamode" id="connmon_dataoutput_average" class="input" value="average" checked>
<label for="connmon_dataoutput_average" class="settingvalue">Average</label>
<input type="radio" name="connmon_outputdatamode" id="connmon_dataoutput_raw" class="input" value="raw">
<label for="connmon_dataoutput_raw" class="settingvalue">Raw</label>
</td>
</tr>
<tr class="even" id="rowtimeoutput">
<th width="40%">Time Output Mode<br/><span style="color:#FFCC00;">(for CSV export)</span></th>
<td class="settingvalue">
<input type="radio" name="connmon_outputtimemode" id="connmon_timeoutput_non-unix" class="input" value="non-unix" checked>
<label for="connmon_timeoutput_non-unix" class="settingvalue">Non-Unix</label>
<input type="radio" name="connmon_outputtimemode" id="connmon_timeoutput_unix" class="input" value="unix">
<label for="connmon_timeoutput_unix" class="settingvalue">Unix</label>
</td>
</tr>
<tr class="even" id="rowstorageloc">
<th width="40%">Data Storage Location</th>
<td class="settingvalue">
<input type="radio" name="connmon_storagelocation" id="connmon_storageloc_jffs" class="input" value="jffs" checked>
<label for="connmon_storageloc_jffs" class="settingvalue">JFFS</label>
<input type="radio" name="connmon_storagelocation" id="connmon_storageloc_usb" class="input" value="usb">
<label for="connmon_storageloc_usb" class="settingvalue">USB</label>
</td>
</tr>
<tr class="apply_gen" valign="top" height="35px">
<td colspan="2" style="background-color:rgb(77, 89, 93);">
<input type="button" onclick="SaveConfig();" value="Save" class="button_gen" name="button">
</td>
</tr>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="2" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:0px;" id="table_buttons2">
<thead class="collapsible-jquery" id="charttools">
<tr><td colspan="2">Chart Display Options (click to expand/collapse)</td></tr>
</thead>
<tr>
<th width="20%"><span style="color:#FFFFFF;">Time format</span><br /><span style="color:#FFCC00;">(for tooltips and Last 24h chart axis)</span></th>
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
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
<thead class="collapsible-jquery" id="chart_ping">
<tr>
<td colspan="2">Ping (click to expand/collapse)</td>
</tr>
</thead>
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
