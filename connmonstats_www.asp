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
p{font-weight:bolder}thead.collapsible-jquery{color:#fff;padding:0;width:100%;border:none;text-align:left;outline:none;cursor:pointer}td.nodata{height:65px!important;border:none!important;text-align:center!important;font:bolder 48px Arial!important}.StatsTable{table-layout:fixed!important;width:747px!important;text-align:center!important}.StatsTable th{background-color:#1F2D35!important;background:#2F3A3E!important;border-bottom:none!important;border-top:none!important;color:#fff!important;padding:4px!important;font-size:11px!important}.StatsTable td{padding:2px!important;word-wrap:break-word!important;overflow-wrap:break-word!important;font-size:12px!important}.StatsTable a{font-weight:bolder!important;text-decoration:underline!important}.StatsTable th:first-child,.StatsTable td:first-child{border-left:none!important}.StatsTable th:last-child,.StatsTable td:last-child{border-right:none!important}.SettingsTable{text-align:left}.SettingsTable input{text-align:left;margin-left:3px!important}.SettingsTable input.savebutton{text-align:center;margin-top:5px;margin-bottom:5px;border-right:solid 1px #000;border-left:solid 1px #000;border-bottom:solid 1px #000}.SettingsTable td.savebutton{border-right:solid 1px #000;border-left:solid 1px #000;border-bottom:solid 1px #000;background-color:#4d595d}.SettingsTable .cronbutton{text-align:center;min-width:50px;width:50px;height:23px;vertical-align:middle}.SettingsTable select{margin-left:3px!important}.SettingsTable label{margin-right:10px!important;vertical-align:top!important}.SettingsTable th{background-color:#1F2D35!important;background:#2F3A3E!important;border-bottom:none!important;border-top:none!important;font-size:12px!important;color:#fff!important;padding:4px!important;font-weight:bolder!important;padding:0!important}.SettingsTable td{word-wrap:break-word!important;overflow-wrap:break-word!important;border-right:none;border-left:none}.SettingsTable span.settingname{background-color:#1F2D35!important;background:#2F3A3E!important}.SettingsTable td.settingname{border-right:solid 1px #000;border-left:solid 1px #000;background-color:#1F2D35!important;background:#2F3A3E!important;width:35%!important}.SettingsTable td.settingvalue{text-align:left!important;border-right:solid 1px #000}.SettingsTable th:first-child{border-left:none!important}.SettingsTable th:last-child{border-right:none!important}.SettingsTable .invalid{background-color:#8b0000!important}.SettingsTable .disabled{background-color:#CCC!important;color:#888!important}.removespacing{padding-left:0!important;margin-left:0!important;margin-bottom:5px!important;text-align:center!important}.schedulespan{display:inline-block!important;width:70px!important;color:#FFF!important;font-weight:700!important}div.schedulesettings{margin-bottom:5px}div.sortTableContainer{height:300px;overflow-y:scroll;width:745px;border:1px solid #000}.sortTable{table-layout:fixed!important;border:none}thead.sortTableHeader th{background-image:linear-gradient(#92a0a5 0%,#66757c 100%);border-top:none!important;border-left:none!important;border-right:none!important;border-bottom:1px solid #000!important;font-weight:bolder;padding:2px;text-align:center;color:#fff;position:sticky;top:0;font-size:11px!important}thead.sortTableHeader th:first-child,thead.sortTableHeader th:last-child{border-right:none!important}thead.sortTableHeader th:first-child,thead.sortTableHeader td:first-child{border-left:none!important}tbody.sortTableContent td{border-bottom:1px solid #000!important;border-left:none!important;border-right:1px solid #000!important;border-top:none!important;padding:2px;text-align:center;overflow:hidden!important;white-space:nowrap!important;font-size:12px!important}tbody.sortTableContent tr.sortRow:nth-child(odd) td{background-color:#2F3A3E!important}tbody.sortTableContent tr.sortRow:nth-child(even) td{background-color:#475A5F!important}th.sortable{cursor:pointer}
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
var $j=jQuery.noConflict(),daysofweek=["Mon","Tues","Wed","Thurs","Fri","Sat","Sun"],pingtestdur=60,arraysortlistlines=[],originalarraysortlistlines=[],sortfield="Time",sortname="Time",sortdir="desc",AltLayout=GetCookie("AltLayout","string");""==AltLayout&&(AltLayout="false");var maxNoCharts=27,currentNoCharts=0,ShowLines=GetCookie("ShowLines","string"),ShowFill=GetCookie("ShowFill","string");""==ShowFill&&(ShowFill="origin");var DragZoom=!0,ChartPan=!1;Chart.defaults.global.defaultFontColor="#CCC",Chart.Tooltip.positioners.cursor=function(a,b){return b};var dataintervallist=["raw","hour","day"],metriclist=["Ping","Jitter","LineQuality"],titlelist=["Ping","Jitter","Quality"],measureunitlist=["ms","ms","%"],chartlist=["daily","weekly","monthly"],timeunitlist=["hour","day","day"],intervallist=[24,7,30],bordercolourlist=["#fc8500","#42ecf5","#ffffff"],backgroundcolourlist=["rgba(252,133,0,0.5)","rgba(66,236,245,0.5)","rgba(255,255,255,0.5)"];function SettingHint(a){for(var b=document.getElementsByTagName("a"),c=0;c<b.length;c++)b[c].onmouseout=nd;return hinttext="My text goes here",1==a&&(hinttext="Hour(s) of day to run ping test<br />* for all<br />Valid numbers between 0 and 23<br />comma (,) separate for multiple<br />dash (-) separate for a range"),2==a&&(hinttext="Minute(s) of day to run ping test<br />(* for all<br />Valid numbers between 0 and 59<br />comma (,) separate for multiple<br />dash (-) separate for a range"),overlib(hinttext,0,0)}function keyHandler(a){82==a.keyCode?($j(document).off("keydown"),ResetZoom()):68==a.keyCode?($j(document).off("keydown"),ToggleDragZoom(document.form.btnDragZoom)):70==a.keyCode?($j(document).off("keydown"),ToggleFill()):76==a.keyCode&&($j(document).off("keydown"),ToggleLines())}$j(document).keydown(function(a){keyHandler(a)}),$j(document).keyup(function(){$j(document).keydown(function(a){keyHandler(a)})});function Validate_IP(a){var b=a.value,c=a.name;return /^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test(b)?($j(a).removeClass("invalid"),!0):($j(a).addClass("invalid"),!1)}function Validate_Domain(a){var b=a.value,c=a.name;return /^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$/.test(b)?($j(a).removeClass("invalid"),!0):($j(a).addClass("invalid"),!1)}function Validate_Number_Setting(a,b,c){var d=a.name,e=1*a.value;return e>b||e<c?($j(a).addClass("invalid"),!1):($j(a).removeClass("invalid"),!0)}function Format_Number_Setting(a){var b=a.name,c=1*a.value;return 0!=a.value.length&&c!=NaN&&(a.value=parseInt(a.value),!0)}function Validate_Schedule(a,b){var c=a.name,d=a.value.split(","),e=0;"hours"==b?e=23:"mins"==b&&(e=59),showhide("btnfixhours",!1),showhide("btnfixmins",!1);for(var f="false",g=0;g<d.length;g++)if("*"==d[g]&&0==g)f="false";else if("*"==d[g]&&0!=g)f="true";else if("*"==d[0]&&0<g)f="true";else if(""==d[g])f="true";else if(d[g].startsWith("*/"))isNaN(1*d[g].replace("*/",""))?f="true":(1*d[g].replace("*/","")>e||0>1*d[g].replace("*/",""))&&(f="true");else if(!(-1!=d[g].indexOf("-")))isNaN(1*d[g])?f="true":(1*d[g]>e||0>1*d[g])&&(f="true");else if(d[g].startsWith("-"))f="true";else for(var h=d[g].split("-"),j=0;j<h.length;j++)""==h[j]?f="true":isNaN(1*h[j])?f="true":1*h[j]>e||0>1*h[j]?f="true":1*h[j+1]<1*h[j]&&(f="true","hours"==b?showhide("btnfixhours",!0):"mins"==b&&showhide("btnfixmins",!0));return"true"==f?($j(a).addClass("invalid"),!1):($j(a).removeClass("invalid"),!0)}function Validate_ScheduleValue(a){var b=a.name,c=1*a.value,d=0,e=$j("#everyxselect").val();return"hours"==e?d=24:"minutes"==e&&(d=30),c>d||c<1||1>a.value.length?($j(a).addClass("invalid"),!1):($j(a).removeClass("invalid"),!0)}function Validate_All(){var a=!1;return Validate_IP(document.form.connmon_ipaddr)||(a=!0),Validate_Domain(document.form.connmon_domain)||(a=!0),Validate_Number_Setting(document.form.connmon_pingduration,60,10)||(a=!0),Validate_Number_Setting(document.form.connmon_lastxresults,100,10)||(a=!0),Validate_Number_Setting(document.form.connmon_daystokeep,365,30)||(a=!0),"EveryX"==document.form.schedulemode.value?!Validate_ScheduleValue(document.form.everyxvalue)&&(a=!0):"Custom"==document.form.schedulemode.value&&(!Validate_Schedule(document.form.connmon_schhours,"hours")&&(a=!0),!Validate_Schedule(document.form.connmon_schmins,"mins")&&(a=!0)),!a||(alert("Validation for some fields failed. Please correct invalid values and try again."),!1)}function FixCron(a){if("hours"==a){var b=document.form.connmon_schhours.value;document.form.connmon_schhours.value=b.split("-")[0]+"-23,0-"+b.split("-")[1],Validate_Schedule(document.form.connmon_schhours,"hours")}else if("mins"==a){var b=document.form.connmon_schmins.value;document.form.connmon_schmins.value=b.split("-")[0]+"-59,0-"+b.split("-")[1],Validate_Schedule(document.form.connmon_schmins,"mins")}}function changePingType(a){var b=a.value,c=a.name;0==b?(document.getElementById("rowip").style.display="",document.getElementById("rowdomain").style.display="none"):(document.getElementById("rowip").style.display="none",document.getElementById("rowdomain").style.display="")}function Draw_Chart_NoData(a){document.getElementById("divLineChart_"+a).width="730",document.getElementById("divLineChart_"+a).height="500",document.getElementById("divLineChart_"+a).style.width="730px",document.getElementById("divLineChart_"+a).style.height="500px";var b=document.getElementById("divLineChart_"+a).getContext("2d");b.save(),b.textAlign="center",b.textBaseline="middle",b.font="normal normal bolder 48px Arial",b.fillStyle="white",b.fillText("Data loading...",365,250),b.restore()}function Draw_Chart(a,b,c,d,e){var f=getChartPeriod($j("#"+a+"_Period option:selected").val()),g=getChartInterval($j("#"+a+"_Interval option:selected").val()),h=timeunitlist[$j("#"+a+"_Period option:selected").val()],i=intervallist[$j("#"+a+"_Period option:selected").val()],j=null,k=moment().subtract(i,h+"s"),l="line",m=window[a+"_"+g+"_"+f];if("undefined"==typeof m||null===m)return void Draw_Chart_NoData(a);if(0==m.length)return void Draw_Chart_NoData(a);var n=m.map(function(a){return a.Metric}),o=m.map(function(a){return{x:a.Time,y:a.Value}}),p=window["LineChart_"+a],q=getTimeFormat($j("#Time_Format option:selected").val(),"axis"),r=getTimeFormat($j("#Time_Format option:selected").val(),"tooltip");"day"==g&&(l="bar",j=moment().endOf("day").subtract(9,"hours"),k=moment().startOf("day").subtract(i-1,h+"s").subtract(12,"hours")),"daily"==f&&"day"==g&&(h="day",i=1,j=moment().endOf("day").subtract(9,"hours"),k=moment().startOf("day").subtract(12,"hours")),factor=0,"hour"==h?factor=3600000:"day"==h&&(factor=86400000),p!=null&&p.destroy();var s=document.getElementById("divLineChart_"+a).getContext("2d"),t={segmentShowStroke:!1,segmentStrokeColor:"#000",animationEasing:"easeOutQuart",animationSteps:100,maintainAspectRatio:!1,animateScale:!0,hover:{mode:"point"},legend:{display:!1,position:"bottom",onClick:null},title:{display:!0,text:b},tooltips:{callbacks:{title:function(a){return"day"==g?moment(a[0].xLabel,"X").format("YYYY-MM-DD"):moment(a[0].xLabel,"X").format(r)},label:function(a,b){return round(b.datasets[a.datasetIndex].data[a.index].y,2).toFixed(2)+" "+c}},mode:"point",position:"cursor",intersect:!0},scales:{xAxes:[{type:"time",gridLines:{display:!0,color:"#282828"},ticks:{min:k,max:j,display:!0},time:{parser:"X",unit:h,stepSize:1,displayFormats:q}}],yAxes:[{type:getChartScale($j("#"+a+"_Scale option:selected").val()),gridLines:{display:!1,color:"#282828"},scaleLabel:{display:!1,labelString:c},ticks:{display:!0,beginAtZero:!0,max:getYAxisMax(a),labels:{index:["min","max"],removeEmptyLines:!0},userCallback:LogarithmicFormatter}}]},plugins:{zoom:{pan:{enabled:ChartPan,mode:"xy",rangeMin:{x:new Date().getTime()-factor*i,y:0},rangeMax:{x:new Date().getTime(),y:getLimit(o,"y","max",!1)+.1*getLimit(o,"y","max",!1)}},zoom:{enabled:!0,drag:DragZoom,mode:"xy",rangeMin:{x:new Date().getTime()-factor*i,y:0},rangeMax:{x:new Date().getTime(),y:getLimit(o,"y","max",!1)+.1*getLimit(o,"y","max",!1)},speed:.1}}},annotation:{drawTime:"afterDatasetsDraw",annotations:[{type:ShowLines,mode:"horizontal",scaleID:"y-axis-0",value:getAverage(o),borderColor:d,borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"center",enabled:!0,xAdjust:0,yAdjust:0,content:"Avg="+round(getAverage(o),2).toFixed(2)+c}},{type:ShowLines,mode:"horizontal",scaleID:"y-axis-0",value:getLimit(o,"y","max",!0),borderColor:d,borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"right",enabled:!0,xAdjust:15,yAdjust:0,content:"Max="+round(getLimit(o,"y","max",!0),2).toFixed(2)+c}},{type:ShowLines,mode:"horizontal",scaleID:"y-axis-0",value:getLimit(o,"y","min",!0),borderColor:d,borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"left",enabled:!0,xAdjust:15,yAdjust:0,content:"Min="+round(getLimit(o,"y","min",!0),2).toFixed(2)+c}}]}},u={labels:n,datasets:[{data:o,borderWidth:1,pointRadius:1,lineTension:0,fill:ShowFill,backgroundColor:e,borderColor:d}]};p=new Chart(s,{type:l,options:t,data:u}),window["LineChart_"+a]=p}function LogarithmicFormatter(a,b,c){var d=this.options.scaleLabel.labelString;if("logarithmic"!=this.type)return isNaN(a)?a+" "+d:round(a,2).toFixed(2)+" "+d;var e=this.options.ticks.labels||{},f=e.index||["min","max"],g=e.significand||[1,2,5],h=a/Math.pow(10,Math.floor(Chart.helpers.log10(a))),i=!0===e.removeEmptyLines?void 0:"",j="";return 0===b?j="min":b==c.length-1&&(j="max"),"all"===e||-1!==g.indexOf(h)||-1!==f.indexOf(b)||-1!==f.indexOf(j)?0===a?"0 "+d:isNaN(a)?a+" "+d:round(a,2).toFixed(2)+" "+d:i}function getLimit(a,b,c,d){var e,f=0;return e="x"==b?a.map(function(a){return a.x}):a.map(function(a){return a.y}),f="max"==c?Math.max.apply(Math,e):Math.min.apply(Math,e),"max"==c&&0==f&&!1==d&&(f=1),f}function getYAxisMax(a){if("LineQuality"==a)return 100}function getAverage(a){for(var b=0,c=0;c<a.length;c++)b+=1*a[c].y;var d=b/a.length;return d}function round(a,b){return+(Math.round(a+"e"+b)+"e-"+b)}function ToggleLines(){""==ShowLines?(ShowLines="line",SetCookie("ShowLines","line")):(ShowLines="",SetCookie("ShowLines",""));for(var a=0;a<metriclist.length;a++){for(var b=0;3>b;b++)window["LineChart_"+metriclist[a]].options.annotation.annotations[b].type=ShowLines;window["LineChart_"+metriclist[a]].update()}}function ToggleFill(){"false"==ShowFill?(ShowFill="origin",SetCookie("ShowFill","origin")):(ShowFill="false",SetCookie("ShowFill","false"));for(var a=0;a<metriclist.length;a++)window["LineChart_"+metriclist[a]].data.datasets[0].fill=ShowFill,window["LineChart_"+metriclist[a]].update()}function RedrawAllCharts(){for(var a=0;a<metriclist.length;a++){Draw_Chart_NoData(metriclist[a]);for(var b=0;b<chartlist.length;b++)for(var c=0;c<dataintervallist.length;c++)d3.csv("/ext/connmon/csv/"+metriclist[a]+"_"+dataintervallist[c]+"_"+chartlist[b]+".htm").then(SetGlobalDataset.bind(null,metriclist[a]+"_"+dataintervallist[c]+"_"+chartlist[b]))}}function SetGlobalDataset(a,b){if(window[a]=b,currentNoCharts++,currentNoCharts==maxNoCharts){showhide("imgConnTest",!1),showhide("conntest_text",!1),showhide("btnRunPingtest",!0);for(var c=0;c<metriclist.length;c++)$j("#"+metriclist[c]+"_Interval").val(GetCookie(metriclist[c]+"_Interval","number")),changePeriod(document.getElementById(metriclist[c]+"_Interval")),$j("#"+metriclist[c]+"_Period").val(GetCookie(metriclist[c]+"_Period","number")),$j("#"+metriclist[c]+"_Scale").val(GetCookie(metriclist[c]+"_Scale","number")),Draw_Chart(metriclist[c],titlelist[c],measureunitlist[c],bordercolourlist[c],backgroundcolourlist[c]);AddEventHandlers(),get_lastx_file()}}function getChartScale(a){var b="";return 0==a?b="linear":1==a&&(b="logarithmic"),b}function getChartInterval(a){var b="raw";return 0==a?b="raw":1==a?b="hour":2==a&&(b="day"),b}function getTimeFormat(a,b){var c;return"axis"==b?0==a?c={millisecond:"HH:mm:ss.SSS",second:"HH:mm:ss",minute:"HH:mm",hour:"HH:mm"}:1==a&&(c={millisecond:"h:mm:ss.SSS A",second:"h:mm:ss A",minute:"h:mm A",hour:"h A"}):"tooltip"==b&&(0==a?c="YYYY-MM-DD HH:mm:ss":1==a&&(c="YYYY-MM-DD h:mm:ss A")),c}function GetCookie(a,b){if(null!=cookie.get("conn_"+a))return cookie.get("conn_"+a);return"string"==b?"":"number"==b?0:void 0}function SetCookie(a,b){cookie.set("conn_"+a,b,3650)}function AddEventHandlers(){$j(".collapsible-jquery").off("click").on("click",function(){$j(this).siblings().toggle("fast",function(){"none"==$j(this).css("display")?SetCookie($j(this).siblings()[0].id,"collapsed"):SetCookie($j(this).siblings()[0].id,"expanded")})}),$j(".collapsible-jquery").each(function(){"collapsed"==GetCookie($j(this)[0].id,"string")?$j(this).siblings().toggle(!1):$j(this).siblings().toggle(!0)})}$j.fn.serializeObject=function(){var b=custom_settings,c=this.serializeArray();$j.each(c,function(){void 0!==b[this.name]&&-1!=this.name.indexOf("connmon")&&-1==this.name.indexOf("version")&&-1==this.name.indexOf("ipaddr")&&-1==this.name.indexOf("domain")&&-1==this.name.indexOf("schdays")?(!b[this.name].push&&(b[this.name]=[b[this.name]]),b[this.name].push(this.value||"")):-1!=this.name.indexOf("connmon")&&-1==this.name.indexOf("version")&&-1==this.name.indexOf("ipaddr")&&-1==this.name.indexOf("domain")&&-1==this.name.indexOf("schdays")&&(b[this.name]=this.value||"")});var a=[];$j.each($j("input[name=\"connmon_schdays\"]:checked"),function(){a.push($j(this).val())});var d=a.join(",");return"Mon,Tues,Wed,Thurs,Fri,Sat,Sun"==d&&(d="*"),b.connmon_schdays=d,b};function SetCurrentPage(){document.form.next_page.value=window.location.pathname.substring(1),document.form.current_page.value=window.location.pathname.substring(1)}function ParseCSVExport(a){for(var b,c="Timestamp,Ping,Jitter,LineQuality,PingTarget,PingDuration\n",d=0;d<a.length;d++)b=a[d].Timestamp+","+a[d].Ping+","+a[d].Jitter+","+a[d].LineQuality+","+a[d].PingTarget+","+a[d].PingDuration,c+=d<a.length-1?b+"\n":b;document.getElementById("aExport").href="data:text/csv;charset=utf-8,"+encodeURIComponent(c)}function ErrorCSVExport(){document.getElementById("aExport").href="javascript:alert('Error exporting CSV, please refresh the page and try again')"}function initial(){SetCurrentPage(),LoadCustomSettings(),show_menu(),$j("#alternatelayout").prop("checked","false"!=AltLayout),$j("#sortTableContainer").empty(),$j("#sortTableContainer").append(BuildLastXTableNoData()),get_conf_file(),d3.csv("/ext/connmon/csv/CompleteResults.htm").then(function(a){ParseCSVExport(a)}).catch(function(){ErrorCSVExport()}),$j("#Time_Format").val(GetCookie("Time_Format","number")),RedrawAllCharts(),ScriptUpdateLayout(),get_statstitle_file()}function ScriptUpdateLayout(){var a=GetVersionNumber("local"),b=GetVersionNumber("server");$j("#connmon_version_local").text(a),a!=b&&"N/A"!=b&&($j("#connmon_version_server").text("Updated version available: "+b),showhide("btnChkUpdate",!1),showhide("connmon_version_server",!0),showhide("btnDoUpdate",!0))}function reload(){location.reload(!0)}function getChartPeriod(a){var b="daily";return 0==a?b="daily":1==a?b="weekly":2==a&&(b="monthly"),b}function ResetZoom(){for(var a,b=0;b<metriclist.length;b++)(a=window["LineChart_"+metriclist[b]],"undefined"!=typeof a&&null!==a)&&a.resetZoom()}function ToggleDragZoom(a){var b=!0,c=!1,d="";-1==a.value.indexOf("On")?(b=!0,c=!1,DragZoom=!0,ChartPan=!1,d="Drag Zoom On"):(b=!1,c=!0,DragZoom=!1,ChartPan=!0,d="Drag Zoom Off");for(var e,f=0;f<metriclist.length;f++)(e=window["LineChart_"+metriclist[f]],"undefined"!=typeof e&&null!==e)&&(e.options.plugins.zoom.zoom.drag=b,e.options.plugins.zoom.pan.enabled=c,a.value=d,e.update())}function ToggleAlternateLayout(a){AltLayout=a.checked.toString(),SetCookie("AltLayout",AltLayout),SortTable(sortname+" "+sortdir.replace("desc","\u2191").replace("asc","\u2193").trim())}function update_status(){$j.ajax({url:"/ext/connmon/detect_update.js",dataType:"script",timeout:3e3,error:function(){setTimeout(update_status,1e3)},success:function(){"InProgress"==updatestatus?setTimeout(update_status,1e3):(document.getElementById("imgChkUpdate").style.display="none",showhide("connmon_version_server",!0),"None"==updatestatus?($j("#connmon_version_server").text("No update available"),showhide("btnChkUpdate",!0),showhide("btnDoUpdate",!1)):($j("#connmon_version_server").text("Updated version available: "+updatestatus),showhide("btnChkUpdate",!1),showhide("btnDoUpdate",!0)))}})}function CheckUpdate(){showhide("btnChkUpdate",!1),document.formScriptActions.action_script.value="start_connmoncheckupdate",document.formScriptActions.submit(),document.getElementById("imgChkUpdate").style.display="",setTimeout(update_status,2e3)}function DoUpdate(){document.form.action_script.value="start_connmondoupdate",document.form.action_wait.value=10,showLoading(),document.form.submit()}function SaveConfig(){if(Validate_All()){if($j("[name*=connmon_]").prop("disabled",!1),0==document.form.pingtype.value?document.form.connmon_pingserver.value=document.form.connmon_ipaddr.value:1==document.form.pingtype.value&&(document.form.connmon_pingserver.value=document.form.connmon_domain.value),"EveryX"==document.form.schedulemode.value)if("hours"==document.form.everyxselect.value){var a=1*document.form.everyxvalue.value;document.form.connmon_schmins.value=0,document.form.connmon_schhours.value=24==a?0:"*/"+a}else if("minutes"==document.form.everyxselect.value){document.form.connmon_schhours.value="*";var a=1*document.form.everyxvalue.value;document.form.connmon_schmins.value="*/"+a}document.getElementById("amng_custom").value=JSON.stringify($j("form").serializeObject()),document.form.action_script.value="start_connmonconfig",document.form.action_wait.value=5,showLoading(),document.form.submit()}else return!1}function GetVersionNumber(a){var b;return"local"==a?b=custom_settings.connmon_version_local:"server"==a&&(b=custom_settings.connmon_version_server),"undefined"==typeof b||null==b?"N/A":b}function get_conntestresult_file(){$j.ajax({url:"/ext/connmon/ping-result.htm",dataType:"text",timeout:1e3,error:function(){setTimeout(get_conntestresult_file,500)},success:function(a){var b=a.trim().split("\n");a=b.join("\n"),$j("#conntest_output").html(a),document.getElementById("conntest_output").parentElement.parentElement.style.display=""}})}function get_conf_file(){$j.ajax({url:"/ext/connmon/config.htm",dataType:"text",error:function(){setTimeout(get_conf_file,1e3)},success:function(data){var configdata=data.split("\n");configdata=configdata.filter(Boolean);for(var i=0;i<configdata.length;i++){let settingname=configdata[i].split("=")[0].toLowerCase(),settingvalue=configdata[i].split("=")[1].replace(/(\r\n|\n|\r)/gm,"");if(-1!=configdata[i].indexOf("PINGSERVER")){var pingserver=settingvalue;document.form.connmon_pingserver.value=pingserver,Validate_IP(document.form.connmon_pingserver)?(document.form.pingtype.value=0,document.form.connmon_ipaddr.value=pingserver):(document.form.pingtype.value=1,document.form.connmon_domain.value=pingserver),document.form.pingtype.onchange()}else if(!(-1!=configdata[i].indexOf("SCHDAYS")))eval("document.form.connmon_"+settingname).value=settingvalue;else if("*"==settingvalue)for(var i2=0;i2<daysofweek.length;i2++)$j("#connmon_"+daysofweek[i2].toLowerCase()).prop("checked",!0);else for(var schdayarray=settingvalue.split(","),i2=0;i2<schdayarray.length;i2++)$j("#connmon_"+schdayarray[i2].toLowerCase()).prop("checked",!0);-1!=configdata[i].indexOf("AUTOMATED")&&AutomaticTestEnableDisable($j("#connmon_auto_"+document.form.connmon_automated.value)[0]),-1!=configdata[i].indexOf("PINGDURATION")&&(pingtestdur=document.form.connmon_pingduration.value)}-1!=$j("[name=connmon_schhours]").val().indexOf("/")&&0==$j("[name=connmon_schmins]").val()?(document.form.schedulemode.value="EveryX",document.form.everyxselect.value="hours",document.form.everyxvalue.value=$j("[name=connmon_schhours]").val().split("/")[1]):-1!=$j("[name=connmon_schmins]").val().indexOf("/")&&"*"==$j("[name=connmon_schhours]").val()?(document.form.schedulemode.value="EveryX",document.form.everyxselect.value="minutes",document.form.everyxvalue.value=$j("[name=connmon_schmins]").val().split("/")[1]):document.form.schedulemode.value="Custom",ScheduleModeToggle($j("#schmode_"+$j("[name=schedulemode]:checked").val().toLowerCase())[0])}})}function get_statstitle_file(){$j.ajax({url:"/ext/connmon/connstatstext.js",dataType:"script",timeout:3e3,error:function(){setTimeout(get_statstitle_file,1e3)},success:function(){SetConnmonStatsTitle()}})}function get_lastx_file(){$j.ajax({url:"/ext/connmon/lastx.htm",dataType:"text",timeout:3e3,error:function(){setTimeout(get_lastx_file,1e3)},success:function(a){ParseLastXData(a)}})}function ParseLastXData(a){var b=a.split("\n");b=b.filter(Boolean),arraysortlistlines=[];for(var c=0;c<b.length;c++)try{var d=b[c].split(","),e={};e.Time=moment.unix(d[0].trim()).format("YYYY-MM-DD HH:mm:ss"),e.Ping=d[1].trim(),e.Jitter=d[2].trim(),e.LineQuality=d[3].replace("null","").trim(),e.Target=d[4].replace("null","").trim(),e.Duration=d[5].replace("null","").trim(),arraysortlistlines.push(e)}catch{}originalarraysortlistlines=arraysortlistlines,SortTable(sortname+" "+sortdir.replace("desc","\u2191").replace("asc","\u2193").trim())}function SortTable(sorttext){sortname=sorttext.replace("\u2191","").replace("\u2193","").trim();var sorttype="number";sortfield=sortname;"Time"===sortname?sorttype="date":"Target"===sortname?sorttype="string":void 0;"string"==sorttype?-1==sorttext.indexOf("\u2193")&&-1==sorttext.indexOf("\u2191")?(eval("arraysortlistlines = arraysortlistlines.sort((a,b) => (a."+sortfield+" > b."+sortfield+") ? 1 : ((b."+sortfield+" > a."+sortfield+") ? -1 : 0));"),sortdir="asc"):-1==sorttext.indexOf("\u2193")?(eval("arraysortlistlines = arraysortlistlines.sort((a,b) => (a."+sortfield+" < b."+sortfield+") ? 1 : ((b."+sortfield+" < a."+sortfield+") ? -1 : 0));"),sortdir="desc"):(eval("arraysortlistlines = arraysortlistlines.sort((a,b) => (a."+sortfield+" > b."+sortfield+") ? 1 : ((b."+sortfield+" > a."+sortfield+") ? -1 : 0));"),sortdir="asc"):"number"==sorttype?-1==sorttext.indexOf("\u2193")&&-1==sorttext.indexOf("\u2191")?(eval("arraysortlistlines = arraysortlistlines.sort((a, b) => parseFloat(a."+sortfield+".replace(\"m\",\"000\")) - parseFloat(b."+sortfield+".replace(\"m\",\"000\")));"),sortdir="asc"):-1==sorttext.indexOf("\u2193")?(eval("arraysortlistlines = arraysortlistlines.sort((a, b) => parseFloat(b."+sortfield+".replace(\"m\",\"000\")) - parseFloat(a."+sortfield+".replace(\"m\",\"000\")));"),sortdir="desc"):(eval("arraysortlistlines = arraysortlistlines.sort((a, b) => parseFloat(a."+sortfield+".replace(\"m\",\"000\")) - parseFloat(b."+sortfield+".replace(\"m\",\"000\"))); "),sortdir="asc"):"date"==sorttype&&(-1==sorttext.indexOf("\u2193")&&-1==sorttext.indexOf("\u2191")?(eval("arraysortlistlines = arraysortlistlines.sort((a, b) => new Date(a."+sortfield+") - new Date(b."+sortfield+"));"),sortdir="asc"):-1==sorttext.indexOf("\u2193")?(eval("arraysortlistlines = arraysortlistlines.sort((a, b) => new Date(b."+sortfield+") - new Date(a."+sortfield+"));"),sortdir="desc"):(eval("arraysortlistlines = arraysortlistlines.sort((a, b) => new Date(a."+sortfield+") - new Date(b."+sortfield+"));"),sortdir="asc")),$j("#sortTableContainer").empty(),$j("#sortTableContainer").append(BuildLastXTable()),$j(".sortable").each(function(a,b){b.innerHTML.replace(/ \(.*\)/,"").replace(" ","")==sortname&&("asc"==sortdir?b.innerHTML+=" \u2191":b.innerHTML+=" \u2193")})}function BuildLastXTableNoData(){var a="<table width=\"100%\" border=\"1\" align=\"center\" cellpadding=\"4\" cellspacing=\"0\" bordercolor=\"#6b8fa3\" class=\"sortTable\">";return a+="<tr>",a+="<td colspan=\"6\" class=\"nodata\">",a+="Data loading...",a+="</td>",a+="</tr>",a+="</table>",a}function BuildLastXTable(){var a="<table width=\"100%\" border=\"1\" align=\"center\" cellpadding=\"4\" cellspacing=\"0\" bordercolor=\"#6b8fa3\" class=\"sortTable\">";if("false"==AltLayout){a+="<col style=\"width:130px;\">",a+="<col style=\"width:200px;\">",a+="<col style=\"width:95px;\">",a+="<col style=\"width:90px;\">",a+="<col style=\"width:90px;\">",a+="<col style=\"width:110px;\">",a+="<thead class=\"sortTableHeader\">",a+="<tr>",a+="<th class=\"sortable\" onclick=\"SortTable(this.innerHTML.replace(/ \\(.*\\)/,''))\">Time</th>",a+="<th class=\"sortable\" onclick=\"SortTable(this.innerHTML.replace(/ \\(.*\\)/,''))\">Target</th>",a+="<th class=\"sortable\" onclick=\"SortTable(this.innerHTML.replace(/ \\(.*\\)/,''))\">Duration (s)</th>",a+="<th class=\"sortable\" onclick=\"SortTable(this.innerHTML.replace(/ \\(.*\\)/,''))\">Ping (ms)</th>",a+="<th class=\"sortable\" onclick=\"SortTable(this.innerHTML.replace(/ \\(.*\\)/,''))\">Jitter (ms)</th>",a+="<th class=\"sortable\" onclick=\"SortTable(this.innerHTML.replace(/ \\(.*\\)/,'').replace(' ',''))\">Line Quality (%)</th>",a+="</tr>",a+="</thead>",a+="<tbody class=\"sortTableContent\">";for(var b=0;b<arraysortlistlines.length;b++)a+="<tr class=\"sortRow\">",a+="<td>"+arraysortlistlines[b].Time+"</td>",a+="<td>"+arraysortlistlines[b].Target+"</td>",a+="<td>"+arraysortlistlines[b].Duration+"</td>",a+="<td>"+arraysortlistlines[b].Ping+"</td>",a+="<td>"+arraysortlistlines[b].Jitter+"</td>",a+="<td>"+arraysortlistlines[b].LineQuality+"</td>",a+="</tr>"}else{a+="<col style=\"width:130px;\">",a+="<col style=\"width:90px;\">",a+="<col style=\"width:90px;\">",a+="<col style=\"width:110px;\">",a+="<col style=\"width:200px;\">",a+="<col style=\"width:95px;\">",a+="<thead class=\"sortTableHeader\">",a+="<tr>",a+="<th class=\"sortable\" onclick=\"SortTable(this.innerHTML.replace(/ \\(.*\\)/,''))\">Time</th>",a+="<th class=\"sortable\" onclick=\"SortTable(this.innerHTML.replace(/ \\(.*\\)/,''))\">Ping (ms)</th>",a+="<th class=\"sortable\" onclick=\"SortTable(this.innerHTML.replace(/ \\(.*\\)/,''))\">Jitter (ms)</th>",a+="<th class=\"sortable\" onclick=\"SortTable(this.innerHTML.replace(/ \\(.*\\)/,'').replace(' ',''))\">Line Quality (%)</th>",a+="<th class=\"sortable\" onclick=\"SortTable(this.innerHTML.replace(/ \\(.*\\)/,''))\">Target</th>",a+="<th class=\"sortable\" onclick=\"SortTable(this.innerHTML.replace(/ \\(.*\\)/,''))\">Duration (s)</th>",a+="</tr>",a+="</thead>",a+="<tbody class=\"sortTableContent\">";for(var b=0;b<arraysortlistlines.length;b++)a+="<tr class=\"sortRow\">",a+="<td>"+arraysortlistlines[b].Time+"</td>",a+="<td>"+arraysortlistlines[b].Ping+"</td>",a+="<td>"+arraysortlistlines[b].Jitter+"</td>",a+="<td>"+arraysortlistlines[b].LineQuality+"</td>",a+="<td>"+arraysortlistlines[b].Target+"</td>",a+="<td>"+arraysortlistlines[b].Duration+"</td>",a+="</tr>"}return a+="</tbody>",a+="</table>",a}function AutomaticTestEnableDisable(a){var b=a.name,c=a.value,d=b.substring(0,b.indexOf("_")),e=["schhours","schmins"],f=["schedulemode","everyxselect","everyxvalue"];if("false"==c){for(var g=0;g<e.length;g++)$j("input[name="+d+"_"+e[g]+"]").addClass("disabled"),$j("input[name="+d+"_"+e[g]+"]").prop("disabled",!0);for(var g=0;g<daysofweek.length;g++)$j("#"+d+"_"+daysofweek[g].toLowerCase()).prop("disabled",!0);for(var g=0;g<f.length;g++)$j("[name="+f[g]+"]").addClass("disabled"),$j("[name="+f[g]+"]").prop("disabled",!0)}else if("true"==c){for(var g=0;g<e.length;g++)$j("input[name="+d+"_"+e[g]+"]").removeClass("disabled"),$j("input[name="+d+"_"+e[g]+"]").prop("disabled",!1);for(var g=0;g<daysofweek.length;g++)$j("#"+d+"_"+daysofweek[g].toLowerCase()).prop("disabled",!1);for(var g=0;g<f.length;g++)$j("[name="+f[g]+"]").removeClass("disabled"),$j("[name="+f[g]+"]").prop("disabled",!1)}}function ScheduleModeToggle(a){var b=a.name,c=a.value;"EveryX"==c?(showhide("schfrequency",!0),showhide("schcustom",!1),"hours"==$j("#everyxselect").val()?(showhide("spanxhours",!0),showhide("spanxminutes",!1)):"minutes"==$j("#everyxselect").val()&&(showhide("spanxhours",!1),showhide("spanxminutes",!0))):"Custom"==c&&(showhide("schfrequency",!1),showhide("schcustom",!0))}function EveryXToggle(a){var b=a.name,c=a.value;"hours"==c?(showhide("spanxhours",!0),showhide("spanxminutes",!1)):"minutes"==c&&(showhide("spanxhours",!1),showhide("spanxminutes",!0)),Validate_ScheduleValue($j("[name=everyxvalue]")[0])}var pingcount=2;function update_conntest(){pingcount++,$j.ajax({url:"/ext/connmon/detect_connmon.js",dataType:"script",timeout:1e3,error:function(){},success:function(){"InProgress"==connmonstatus?(showhide("imgConnTest",!0),showhide("conntest_text",!0),document.getElementById("conntest_text").innerHTML="Ping test in progress - "+pingcount+"s elapsed"):"GenerateCSV"==connmonstatus?document.getElementById("conntest_text").innerHTML="Retrieving data for charts...":"Done"==connmonstatus?(pingcount=2,clearInterval(myinterval),get_conntestresult_file(),document.getElementById("conntest_text").innerHTML="Refreshing charts...",PostConnTest()):"LOCKED"==connmonstatus?(pingcount=2,clearInterval(myinterval),showhide("imgConnTest",!1),document.getElementById("conntest_text").innerHTML="Scheduled ping test already running!",showhide("conntest_text",!0),showhide("btnRunPingtest",!0),document.getElementById("conntest_output").parentElement.parentElement.style.display="none"):"InvalidServer"==connmonstatus&&(pingcount=2,clearInterval(myinterval),showhide("imgConnTest",!1),document.getElementById("conntest_text").innerHTML="Specified ping server is not valid",showhide("conntest_text",!0),showhide("btnRunPingtest",!0),document.getElementById("conntest_output").parentElement.parentElement.style.display="none")}})}function PostConnTest(){currentNoCharts=0,$j("#Time_Format").val(GetCookie("Time_Format","number")),get_statstitle_file(),setTimeout(RedrawAllCharts,3e3)}function runPingTest(){showhide("btnRunPingtest",!1),$j("#conntest_output").html(""),document.getElementById("conntest_output").parentElement.parentElement.style.display="none",document.formScriptActions.action_script.value="start_connmon",document.formScriptActions.submit(),showhide("imgConnTest",!0),showhide("conntest_text",!1),setTimeout(StartConnTestInterval,2e3)}var myinterval;function StartConnTestInterval(){myinterval=setInterval(update_conntest,1e3)}function changeAllCharts(a){value=1*a.value,name=a.id.substring(0,a.id.indexOf("_")),SetCookie(a.id,value);for(var b=0;b<metriclist.length;b++)Draw_Chart(metriclist[b],titlelist[b],measureunitlist[b],bordercolourlist[b],backgroundcolourlist[b])}function changeChart(a){value=1*a.value,name=a.id.substring(0,a.id.indexOf("_")),SetCookie(a.id,value),"Ping"==name?Draw_Chart("Ping",titlelist[0],measureunitlist[0],bordercolourlist[0],backgroundcolourlist[0]):"Jitter"==name?Draw_Chart("Jitter",titlelist[1],measureunitlist[1],bordercolourlist[1],backgroundcolourlist[1]):"LineQuality"==name&&Draw_Chart("LineQuality",titlelist[2],measureunitlist[2],bordercolourlist[2],backgroundcolourlist[2])}function changePeriod(a){value=1*a.value,name=a.id.substring(0,a.id.indexOf("_")),2==value?$j("select[id=\""+name+"_Period\"] option:contains(24)").text("Today"):$j("select[id=\""+name+"_Period\"] option:contains(\"Today\")").text("Last 24 hours")}
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
<input autocomplete="off" type="text" maxlength="15" class="input_15_table removespacing" name="connmon_ipaddr" value="8.8.8.8" onkeypress="return validator.isIPAddr(this,event)" onblur="Validate_IP(this)" onkeyup="Validate_IP(this)" data-lpignore="true" />
</td>
</tr>
<tr class="even" id="rowdomain">
<td class="settingname">Domain</td>
<td class="settingvalue">
<input autocorrect="off" autocapitalize="off" type="text" maxlength="255" class="input_32_table removespacing" name="connmon_domain" value="google.co.uk" onkeypress="return validator.isString(this,event);" onblur="Validate_Domain(this)" onkeyup="Validate_Domain(this)" data-lpignore="true" />
</td>
</tr>
<tr class="even" id="rowpingdur">
<td class="settingname">Ping test duration</td>
<td class="settingvalue">
<input autocomplete="off" type="text" maxlength="2" class="input_3_table removespacing" name="connmon_pingduration" value="60" onkeypress="return validator.isNumber(this,event)" onblur="Validate_Number_Setting(this,60,10);Format_Number_Setting(this)" onkeyup="Validate_Number_Setting(this,60,10)"/>
&nbsp;seconds <span style="color:#FFCC00;">(between 10 and 60, default: 60)</span>
</td>
</tr>
<tr class="even" id="rowlastxresults">
<td class="settingname">Last X results to display</td>
<td class="settingvalue">
<input autocomplete="off" type="text" maxlength="3" class="input_6_table removespacing" name="connmon_lastxresults" value="10" onkeypress="return validator.isNumber(this,event)" onblur="Validate_Number_Setting(this,100,1);Format_Number_Setting(this)" onkeyup="Validate_Number_Setting(this,100,1)"/>
&nbsp;results <span style="color:#FFCC00;">(between 1 and 100, default: 10)</span>
</td>
</tr>
<tr class="even" id="rowdaystokeep">
<td class="settingname">Number of days of data to keep</td>
<td class="settingvalue">
<input autocomplete="off" type="text" maxlength="3" class="input_6_table removespacing" name="connmon_daystokeep" value="30" onkeypress="return validator.isNumber(this,event)" onblur="Validate_Number_Setting(this,365,30);Format_Number_Setting(this)" onkeyup="Validate_Number_Setting(this,365,30)"/>
&nbsp;days <span style="color:#FFCC00;">(between 30 and 365, default: 30)</span>
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
<tr class="even" id="rowexcludefromqos">
<td class="settingname">Exclude ping tests from QoS</td>
<td class="settingvalue">
<input type="radio" name="connmon_excludefromqos" id="connmon_exclude_true" class="input" value="true" checked>
<label for="connmon_exclude_true">Yes</label>
<input type="radio" name="connmon_excludefromqos" id="connmon_exclude_false" class="input" value="false">
<label for="connmon_exclude_false">No</label>
</td>
</tr>
<tr class="apply_gen" valign="top" height="35px">
<td colspan="2" class="savebutton">
<input type="button" onclick="SaveConfig();" value="Save" class="button_gen savebutton" name="button">
</td>
</tr>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="resulttable_pings">
<thead class="collapsible-jquery" id="resultthead_pings">
<tr><td colspan="2">Latest ping test results (click to expand/collapse)</td></tr>
</thead>
<tr class="even">
<th width="35%">Move target and duration columns to end of table?</th>
<td width="65%">
<label style="color:#FFCC00;display:block;"><input type="checkbox" id="alternatelayout" onclick="ToggleAlternateLayout(this)" style="padding:0;margin:0;vertical-align:middle;position:relative;top:-1px;" /></label>
</td>
</tr>
<tr><td colspan="2"></td></tr>
<tr>
<td colspan="2" align="center" style="padding: 0px;">
<div id="sortTableContainer" class="sortTableContainer"></div>
</td>
</tr>
</table>
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
