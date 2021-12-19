<!DOCTYPE html
	PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="X-UA-Compatible" content="IE=Edge" />
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta http-equiv="Pragma" content="no-cache">
	<meta http-equiv="Expires" content="-1">
	<link rel="shortcut icon" href="images/favicon.png">
	<link rel="icon" href="images/favicon.png">
	<title>connmon</title>
	<link rel="stylesheet" type="text/css" href="index_style.css">
	<link rel="stylesheet" type="text/css" href="form_style.css">
	<link rel="stylesheet" href="/ext/shared-jy/iziToast.min.css">
	<style>
	p{font-weight:bolder}thead.collapsible-jquery{color:#fff;padding:0;width:100%;border:none;text-align:left;outline:none}td.nodata{height:65px;border:none;text-align:center;font:bolder 48px Arial,sans-serif}.SettingsTable{text-align:left}.SettingsTable input{margin-left:3px;margin-top:3px}.SettingsTable input.savebutton{text-align:center;margin-top:3px;margin-bottom:3px;border-right:solid 1px #000;border-left:solid 1px #000;border-bottom:solid 1px #000}.SettingsTable .cronbutton{text-align:center;min-width:50px;width:50px;height:23px;vertical-align:middle}.SettingsTable select{margin-left:3px}.SettingsTable label{margin-right:10px;vertical-align:top}.SettingsTable th{background-color:#2f3a3e;border-bottom:none;border-top:none;font-size:12px;color:#fff;padding:4px;font-weight:bolder}.SettingsTable td{word-wrap:break-word;overflow-wrap:break-word;border-right:none;border-left:none}.SettingsTable span.settingname{background-color:#2f3a3e}.SettingsTable td.settingname{border-right:solid 1px #000;border-left:solid 1px #000;background-color:#2f3a3e;width:35%}.SettingsTable td.settingvalue{text-align:left;border-right:solid 1px #000}.SettingsTable th:first-child{border-left:none}.SettingsTable th:last-child{border-right:none}.SettingsTable .invalid{background-color:#8b0000}.SettingsTable .disabled{background-color:#ccc;color:#888}.removespacing{padding-left:0;margin-left:0;margin-bottom:5px;text-align:center}.FormTable td .schedulespan{display:inline-block;width:70px;color:#fff;font-weight:700}div.schedulesettings{margin-bottom:5px}div.sortTableContainer{height:715px;overflow-y:scroll;width:745px;border:1px solid #000}.sortTable{table-layout:fixed;border:none}thead.sortTableHeader th{background-image:linear-gradient(#92a0a5 0%,#66757c 100%);border-top:none;border-left:none;border-right:none;border-bottom:1px solid #000;font-weight:bolder;padding:2px;text-align:center;color:#fff;position:sticky;top:0;font-size:11px}tbody.sortTableContent td{border-bottom:1px solid #000;border-left:none;border-right:1px solid #000;border-top:none;padding:2px;text-align:center;overflow:hidden;white-space:nowrap;font-size:12px}tbody.sortTableContent tr.sortRow:nth-child(odd) td{background-color:#2f3a3e}tbody.sortTableContent tr.sortRow:nth-child(even) td{background-color:#475a5f}thead.sortTableHeader th:first-child,thead.sortTableHeader th:last-child{border-right:none}thead.sortTableHeader th:first-child,thead.sortTableHeader td:first-child{border-left:none}th.sortable{cursor:pointer}td.savebutton{border:0;background-color:#4d595d}.testbutton{text-align:center;min-width:75px;width:75px;margin-bottom:3px;vertical-align:middle;height:24px}.navbutton{text-align:center;min-width:122px;width:122px;vertical-align:middle;height:55px}.chartnavbutton{text-align:center;min-width:122px;width:122px;vertical-align:middle;margin:5px}.notificationtypenavbutton{text-align:center;min-width:122px;width:122px;vertical-align:middle;height:55px;margin:5px}.notificationmethodnavbutton{text-align:center;min-width:120px;width:120px;vertical-align:middle;height:55px;margin-top:5px;margin-bottom:5px;padding:3px}.notificationtype{display:inline-block;min-width:80px}textarea.settings{background:#596e74;width:98%}
	</style>
	<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/jquery.js"></script>
	<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/moment.js"></script>
	<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chart.js"></script>
	<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/hammerjs.js"></script>
	<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chartjs-plugin-zoom.js"></script>
	<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chartjs-plugin-annotation.js"></script>
	<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/d3.js"></script>
	<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/iziToast.min.js"></script>
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
		var customSettings;
		function loadCustomSettings() {
			customSettings = <% get_custom_settings(); %>;
			for (var prop in customSettings) {
				if (Object.prototype.hasOwnProperty.call(customSettings, prop)) {
					if (prop.indexOf('connmon') !== -1 && prop.indexOf('connmon_version') === -1) {
						eval('delete customSettings.' + prop)
					}
					if (prop.indexOf('email') !== -1) {
						eval('delete customSettings.' + prop)
					}
				}
			}
		}
		var $j=jQuery.noConflict();function getCookie(t,e){return null!==cookie.get("conn_"+t)?"string"===e?cookie.get("conn_"+t):"number"===e?+cookie.get("conn_"+t):void 0:"string"===e?"":"number"===e?0:void 0}function setCookie(t,e){cookie.set("conn_"+t,e,3650)}iziToast.settings({title:"connmon",timeout:5e3,resetOnHover:!1,transitionIn:"fadeInRight",transitionOut:"fadeOutRight",position:"bottomRight",messageSize:"16px",theme:"light",displayMode:"replace",layout:2,drag:!1,pauseOnHover:!1});var daysofweek=["Mon","Tues","Wed","Thurs","Fri","Sat","Sun"],pingtestdur=60,arraysortlistlines=[],sortname="Time",sortdir="desc",AltLayout=getCookie("AltLayout","string");""===AltLayout&&(AltLayout="false");var maxNoCharts=27,currentNoCharts=0,ShowLines=getCookie("ShowLines","string"),ShowFill=getCookie("ShowFill","string");""===ShowFill&&(ShowFill="origin");var DragZoom=!0,ChartPan=!1,myinterval,intervalclear=!1,pingtestrunning=!1;Chart.defaults.global.defaultFontColor="#CCC",Chart.Tooltip.positioners.cursor=function(t,e){return e};var dataintervallist=["raw","hour","day"],metriclist=["Ping","Jitter","LineQuality"],titlelist=["Ping","Jitter","Quality"],measureunitlist=["ms","ms","%"],chartlist=["daily","weekly","monthly"],timeunitlist=["hour","day","day"],intervallist=[24,7,30],bordercolourlist=["#fc8500","#42ecf5","#fff"],backgroundcolourlist=["rgba(252,133,0,0.5)","rgba(66,236,245,0.5)","rgba(255,255,255,0.5)"];function settingHint(t){t=+t;for(var e=document.getElementsByTagName("a"),n=0;n<e.length;n++)e[n].onmouseout=nd;return overlib(2===t?"Minute(s) of day to run ping test<br />(* for all<br />Valid numbers between 0 and 59<br />comma (,) separate for multiple<br />dash (-) separate for a range":1===t?"Hour(s) of day to run ping test<br />* for all<br />Valid numbers between 0 and 23<br />comma (,) separate for multiple<br />dash (-) separate for a range":"My text goes here",0,0)}function resetZoom(){for(var t=0;t<metriclist.length;t++){var e=window["LineChart_"+metriclist[t]];null!=e&&e.resetZoom()}}function toggleDragZoom(t){for(var e=!0,n=!1,o="",o=-1!==t.value.indexOf("On")?(ChartPan=!(DragZoom=!(n=!(e=!1))),"Drag Zoom Off"):(ChartPan=!(DragZoom=!(n=!(e=!0))),"Drag Zoom On"),i=0;i<metriclist.length;i++){var a=window["LineChart_"+metriclist[i]];null!=a&&(a.options.plugins.zoom.zoom.drag=e,a.options.plugins.zoom.pan.enabled=n,t.value=o,a.update())}}function toggleLines(){setCookie("ShowLines",ShowLines=""===ShowLines?"line":"");for(var t=0;t<metriclist.length;t++){for(var e=0;e<3;e++)window["LineChart_"+metriclist[t]].options.annotation.annotations[e].type=ShowLines;window["LineChart_"+metriclist[t]].update()}}function toggleFill(){setCookie("ShowFill",ShowFill="false"===ShowFill?"origin":"false");for(var t=0;t<metriclist.length;t++)window["LineChart_"+metriclist[t]].data.datasets[0].fill=ShowFill,window["LineChart_"+metriclist[t]].update()}function keyHandler(t){switch(t.keyCode){case 82:$j(document).off("keydown"),resetZoom();break;case 68:$j(document).off("keydown"),toggleDragZoom(document.form.btnDragZoom);break;case 70:$j(document).off("keydown"),toggleFill();break;case 76:$j(document).off("keydown"),toggleLines()}}function validateIP(t){var e=t.value;t.name;return/^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test(e)?($j(t).removeClass("invalid"),!0):($j(t).addClass("invalid"),!1)}function validateDomain(t){var e=t.value;t.name;return/^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$/.test(e)?($j(t).removeClass("invalid"),!0):($j(t).addClass("invalid"),!1)}function validateNumberSetting(t,e,n){t.name;var o=+t.value;return e<o||o<n?($j(t).addClass("invalid"),!1):($j(t).removeClass("invalid"),!0)}function formatNumberSetting(t){t.name;var e=+t.value;return 0!==t.value.length&&!isNaN(e)&&(t.value=parseInt(t.value,10),!0)}function formatNumberSetting3DP(t){t.name;var e=+t.value;return!(e<0||0===t.value.length||isNaN(e)||"."===t.value)&&(t.value=parseFloat(t.value).toFixed(3),!0)}function validateSchedule(t,e){t.name;var n=t.value.split(","),o=0;"hours"===e?o=23:"mins"===e&&(o=59),showhide("btnfixhours",!1),showhide("btnfixmins",!1);for(var i="false",a=0;a<n.length;a++)if("*"===n[a]&&0===a)i="false";else if("*"===n[a]&&0!==a)i="true";else if("*"===n[0]&&0<a)i="true";else if(""===n[a])i="true";else if(n[a].startsWith("*/"))(isNaN(+n[a].replace("*/",""))||+n[a].replace("*/","")>o||+n[a].replace("*/","")<0)&&(i="true");else if(-1!==n[a].indexOf("-"))if(n[a].startsWith("-"))i="true";else for(var s=n[a].split("-"),r=0;r<s.length;r++)""===s[r]||isNaN(+s[r])||+s[r]>o||+s[r]<0?i="true":+s[r+1]<+s[r]&&(i="true","hours"===e?showhide("btnfixhours",!0):"mins"===e&&showhide("btnfixmins",!0));else(isNaN(+n[a])||+n[a]>o||+n[a]<0)&&(i="true");return"true"===i?($j(t).addClass("invalid"),!1):($j(t).removeClass("invalid"),!0)}function validateScheduleValue(t){t.name;var e=+t.value,n=0,o=$j("#everyxselect").val();return"hours"===o?n=24:"minutes"===o&&(n=30),n<e||e<1||t.value.length<1?($j(t).addClass("invalid"),!1):($j(t).removeClass("invalid"),!0)}function validateAll(){var t=!1;return validateIP(document.form.connmon_ipaddr)||(t=!0),validateDomain(document.form.connmon_domain)||(t=!0),validateNumberSetting(document.form.connmon_pingduration,60,10)||(t=!0),validateNumberSetting(document.form.connmon_lastxresults,100,10)||(t=!0),validateNumberSetting(document.form.connmon_daystokeep,365,30)||(t=!0),"EveryX"===document.form.schedulemode.value?validateScheduleValue(document.form.everyxvalue)||(t=!0):"Custom"===document.form.schedulemode.value&&(validateSchedule(document.form.connmon_schhours,"hours")||(t=!0),validateSchedule(document.form.connmon_schmins,"mins")||(t=!0)),!t||(alert("Validation for some fields failed. Please correct invalid values and try again."),!1)}function fixCron(t){var e;"hours"===t?(e=document.form.connmon_schhours.value,document.form.connmon_schhours.value=e.split("-")[0]+"-23,0-"+e.split("-")[1],validateSchedule(document.form.connmon_schhours,"hours")):"mins"===t&&(e=document.form.connmon_schmins.value,document.form.connmon_schmins.value=e.split("-")[0]+"-59,0-"+e.split("-")[1],validateSchedule(document.form.connmon_schmins,"mins"))}function changePingType(t){var e=+t.value;t.name;0==e?(document.getElementById("rowip").style.display="",document.getElementById("rowdomain").style.display="none"):(document.getElementById("rowip").style.display="none",document.getElementById("rowdomain").style.display="")}function getTimeFormat(t,e){var n;return t=+t,"axis"===e?0===t?n={millisecond:"HH:mm:ss.SSS",second:"HH:mm:ss",minute:"HH:mm",hour:"HH:mm"}:1===t&&(n={millisecond:"h:mm:ss.SSS A",second:"h:mm:ss A",minute:"h:mm A",hour:"h A"}):"tooltip"===e&&(0===t?n="YYYY-MM-DD HH:mm:ss":1===t&&(n="YYYY-MM-DD h:mm:ss A")),n}function logarithmicFormatter(t,e,n){var o=this.options.scaleLabel.labelString;if("logarithmic"!==this.type)return isNaN(t)?t+" "+o:round(t,2).toFixed(2)+" "+o;var i=this.options.ticks.labels||{},a=i.index||["min","max"],s=i.significand||[1,2,5],r=t/Math.pow(10,Math.floor(Chart.helpers.log10(t))),l=!0===i.removeEmptyLines?void 0:"",c="";return 0===e?c="min":e===n.length-1&&(c="max"),"all"===i||-1!==s.indexOf(r)||-1!==a.indexOf(e)||-1!==a.indexOf(c)?0===t?"0 "+o:isNaN(t)?t+" "+o:round(t,2).toFixed(2)+" "+o:l}function getLimit(t,e,n,o){var i=0,t="x"===e?t.map(function(t){return t.x}):t.map(function(t){return t.y}),i=("max"===n?Math.max:Math.min).apply(Math,t);return"max"===n&&0===i&&!1===o&&(i=1),i}function getYAxisMax(t){if("LineQuality"===t)return 100}function getAverage(t){for(var e=0,n=0;n<t.length;n++)e+=+t[n].y;return e/t.length}function round(t,e){return Number(Math.round(t+"e"+e)+"e-"+e)}function getChartScale(t){var e="";return 0===(t=+t)?e="linear":1===t&&(e="logarithmic"),e}function getChartInterval(t){var e="raw";return 0===(t=+t)?e="raw":1===t?e="hour":2===t&&(e="day"),e}function getChartPeriod(t){var e="daily";return 0===(t=+t)?e="daily":1===t?e="weekly":2===t&&(e="monthly"),e}function drawChartNoData(t,e){document.getElementById("divLineChart_"+t).width="730",document.getElementById("divLineChart_"+t).height="500",document.getElementById("divLineChart_"+t).style.width="730px",document.getElementById("divLineChart_"+t).style.height="500px";t=document.getElementById("divLineChart_"+t).getContext("2d");t.save(),t.textAlign="center",t.textBaseline="middle",t.font="normal normal bolder 48px Arial sans-serif",t.fillStyle="white",t.fillText(e,365,250),t.restore()}function drawChart(t,e,n,o,i){var a,s,r,l,c=getChartPeriod($j("#"+t+"_Period option:selected").val()),m=getChartInterval($j("#"+t+"_Interval option:selected").val()),d=timeunitlist[$j("#"+t+"_Period option:selected").val()],u=intervallist[$j("#"+t+"_Period option:selected").val()],h=moment(),f=null,g=moment().subtract(u,d+"s"),p="line",v=window[t+"_"+m+"_"+c];null!=v&&0!==v.length?(a=v.map(function(t){return t.Metric}),s=v.map(function(t){return{x:t.Time,y:t.Value}}),l=window["LineChart_"+t],v=getTimeFormat($j("#Time_Format option:selected").val(),"axis"),r=getTimeFormat($j("#Time_Format option:selected").val(),"tooltip"),"day"===m&&(p="bar",f=moment().endOf("day").subtract(9,"hours"),g=moment().startOf("day").subtract(u-1,d+"s").subtract(12,"hours"),h=f),"daily"===c&&"day"===m&&(d="day",u=1,f=moment().endOf("day").subtract(9,"hours"),g=moment().startOf("day").subtract(12,"hours"),h=f),factor=0,"hour"===d?factor=36e5:"day"===d&&(factor=864e5),void 0!==l&&l.destroy(),u=document.getElementById("divLineChart_"+t).getContext("2d"),h={segmentShowStroke:!1,segmentStrokeColor:"#000",animationEasing:"easeOutQuart",animationSteps:100,maintainAspectRatio:!1,animateScale:!0,hover:{mode:"point"},legend:{display:!1,position:"bottom",onClick:null},title:{display:!0,text:e},tooltips:{callbacks:{title:function(t,e){return"day"===m?moment(t[0].xLabel,"X").format("YYYY-MM-DD"):moment(t[0].xLabel,"X").format(r)},label:function(t,e){return round(e.datasets[t.datasetIndex].data[t.index].y,2).toFixed(2)+" "+n}},mode:"point",position:"cursor",intersect:!0},scales:{xAxes:[{type:"time",gridLines:{display:!0,color:"#282828"},ticks:{min:g,max:f,display:!0},time:{parser:"X",unit:d,stepSize:1,displayFormats:v}}],yAxes:[{type:getChartScale($j("#"+t+"_Scale option:selected").val()),gridLines:{display:!1,color:"#282828"},scaleLabel:{display:!1,labelString:n},ticks:{display:!0,beginAtZero:!0,max:getYAxisMax(t),labels:{index:["min","max"],removeEmptyLines:!0},userCallback:logarithmicFormatter}}]},plugins:{zoom:{pan:{enabled:ChartPan,mode:"xy",rangeMin:{x:g,y:0},rangeMax:{x:h,y:getLimit(s,"y","max",!1)+.1*getLimit(s,"y","max",!1)}},zoom:{enabled:!0,drag:DragZoom,mode:"xy",rangeMin:{x:g,y:0},rangeMax:{x:h,y:getLimit(s,"y","max",!1)+.1*getLimit(s,"y","max",!1)},speed:.1}}},annotation:{drawTime:"afterDatasetsDraw",annotations:[{type:ShowLines,mode:"horizontal",scaleID:"y-axis-0",value:getAverage(s),borderColor:o,borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"center",enabled:!0,xAdjust:0,yAdjust:0,content:"Avg="+round(getAverage(s),2).toFixed(2)+n}},{type:ShowLines,mode:"horizontal",scaleID:"y-axis-0",value:getLimit(s,"y","max",!0),borderColor:o,borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"right",enabled:!0,xAdjust:15,yAdjust:0,content:"Max="+round(getLimit(s,"y","max",!0),2).toFixed(2)+n}},{type:ShowLines,mode:"horizontal",scaleID:"y-axis-0",value:getLimit(s,"y","min",!0),borderColor:o,borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"left",enabled:!0,xAdjust:15,yAdjust:0,content:"Min="+round(getLimit(s,"y","min",!0),2).toFixed(2)+n}}]}},l=new Chart(u,{type:p,options:h,data:{labels:a,datasets:[{data:s,borderWidth:1,pointRadius:1,lineTension:0,fill:ShowFill,backgroundColor:i,borderColor:o}]}}),window["LineChart_"+t]=l):drawChartNoData(t,"No data to display")}function changePeriod(t){value=+t.value,name=t.id.substring(0,t.id.indexOf("_")),2===value?$j('select[id="'+name+'_Period"] option:contains(24)').text("Today"):$j('select[id="'+name+'_Period"] option:contains("Today")').text("Last 24 hours")}function getLastXFile(){$j.ajax({url:"/ext/connmon/lastx.htm",dataType:"text",cache:!1,error:function(t){setTimeout(getLastXFile,1e3)},success:function(t){parseLastXData(t)}})}function setGlobalDataset(t,e){if(window[t]=e,++currentNoCharts===maxNoCharts){showhide("imgConnTest",!1),showhide("conntest_text",!1),showhide("btnRunPingtest",!0),pingtestrunning&&(pingtestrunning=!1,iziToast.destroy(),iziToast.success({message:"Ping test complete"}));for(var n=0;n<metriclist.length;n++)$j("#"+metriclist[n]+"_Interval").val(getCookie(metriclist[n]+"_Interval","number")),changePeriod(document.getElementById(metriclist[n]+"_Interval")),$j("#"+metriclist[n]+"_Period").val(getCookie(metriclist[n]+"_Period","number")),$j("#"+metriclist[n]+"_Scale").val(getCookie(metriclist[n]+"_Scale","number")),drawChart(metriclist[n],titlelist[n],measureunitlist[n],bordercolourlist[n],backgroundcolourlist[n]);getLastXFile()}}function redrawAllCharts(){for(var t=0;t<metriclist.length;t++){drawChartNoData(metriclist[t],"Data loading...");for(var e=0;e<chartlist.length;e++)for(var n=0;n<dataintervallist.length;n++)d3.csv("/ext/connmon/csv/"+metriclist[t]+"_"+dataintervallist[n]+"_"+chartlist[e]+".htm").then(setGlobalDataset.bind(null,metriclist[t]+"_"+dataintervallist[n]+"_"+chartlist[e]))}}function sortTable(sorttext){sortname=sorttext.replace("↑","").replace("↓","").trim();var sorttype="number",sortfield=sortname;switch(sortname){case"Time":sorttype="date";break;case"Target":sorttype="string"}"string"===sorttype?sortdir=-1===sorttext.indexOf("↓")&&-1===sorttext.indexOf("↑")||-1!==sorttext.indexOf("↓")?(eval("arraysortlistlines = arraysortlistlines.sort((a,b) => (a."+sortfield+" > b."+sortfield+") ? 1 : ((b."+sortfield+" > a."+sortfield+") ? -1 : 0));"),"asc"):(eval("arraysortlistlines = arraysortlistlines.sort((a,b) => (a."+sortfield+" < b."+sortfield+") ? 1 : ((b."+sortfield+" < a."+sortfield+") ? -1 : 0));"),"desc"):"number"===sorttype?sortdir=-1===sorttext.indexOf("↓")&&-1===sorttext.indexOf("↑")?(eval("arraysortlistlines = arraysortlistlines.sort((a,b) => parseFloat(a."+sortfield+'.replace("m","000")) - parseFloat(b.'+sortfield+'.replace("m","000")));'),"asc"):-1!==sorttext.indexOf("↓")?(eval("arraysortlistlines = arraysortlistlines.sort((a,b) => parseFloat(a."+sortfield+'.replace("m","000")) - parseFloat(b.'+sortfield+'.replace("m","000"))); '),"asc"):(eval("arraysortlistlines = arraysortlistlines.sort((a,b) => parseFloat(b."+sortfield+'.replace("m","000")) - parseFloat(a.'+sortfield+'.replace("m","000")));'),"desc"):"date"===sorttype&&(sortdir=-1===sorttext.indexOf("↓")&&-1===sorttext.indexOf("↑")||-1!==sorttext.indexOf("↓")?(eval("arraysortlistlines = arraysortlistlines.sort((a,b) => new Date(a."+sortfield+") - new Date(b."+sortfield+"));"),"asc"):(eval("arraysortlistlines = arraysortlistlines.sort((a,b) => new Date(b."+sortfield+") - new Date(a."+sortfield+"));"),"desc")),$j("#sortTableContainer").empty(),$j("#sortTableContainer").append(buildLastXTable()),$j(".sortable").each(function(t,e){e.innerHTML.replace(/ \(.*\)/,"").replace(" ","")===sortname&&("asc"===sortdir?$j(e).html(e.innerHTML+" ↑"):$j(e).html(e.innerHTML+" ↓"))})}function parseLastXData(t){var e=(e=t.split("\n")).filter(Boolean);arraysortlistlines=[];for(var n=0;n<e.length;n++)try{var o=e[n].split(","),i=new Object;i.Time=moment.unix(o[0].trim()).format("YYYY-MM-DD HH:mm:ss"),i.Ping=o[1].trim(),i.Jitter=o[2].trim(),i.LineQuality=o[3].replace("null","").trim(),i.Target=o[4].replace("null","").trim(),i.Duration=o[5].replace("null","").trim(),arraysortlistlines.push(i)}catch{}sortTable(sortname+" "+sortdir.replace("desc","↑").replace("asc","↓").trim())}function setCurrentPage(){document.form.next_page.value=window.location.pathname.substring(1),document.form.current_page.value=window.location.pathname.substring(1)}function parseCSVExport(t){for(var e="Timestamp,Ping,Jitter,LineQuality,PingTarget,PingDuration\n",n=0;n<t.length;n++){var o=t[n].Timestamp+","+t[n].Ping+","+t[n].Jitter+","+t[n].LineQuality+","+t[n].PingTarget+","+t[n].PingDuration;e+=n<t.length-1?o+"\n":o}document.getElementById("aExport").href="data:text/csv;charset=utf-8,"+encodeURIComponent(e)}function errorCSVExport(){document.getElementById("aExport").href="javascript:alert('Error exporting CSV,please refresh the page and try again')"}function jyNavigate(t,e,n){for(var o=1;o<=n;o++)0===t?($j("#"+e+"Navigate"+o).show(),$j("#btn"+e+"Navigate"+o).css("background",""),$j("#btn"+e+"Navigate0").css({background:"linear-gradient(#09639C 0%,#003047 100%)"})):(o===t?($j("#"+e+"Navigate"+o).show(),$j("#btn"+e+"Navigate"+o).css({background:"linear-gradient(#09639C 0%,#003047 100%)"})):($j("#"+e+"Navigate"+o).hide(),$j("#btn"+e+"Navigate"+o).css("background","")),$j("#btn"+e+"Navigate0").css("background",""))}function automaticTestEnableDisable(t){var e=t.name,t=t.value,n=e.substring(0,e.indexOf("_")),o=["schhours","schmins"],i=["schedulemode","everyxselect","everyxvalue"];if("false"===t){for(var a=0;a<o.length;a++)$j("input[name="+n+"_"+o[a]+"]").addClass("disabled"),$j("input[name="+n+"_"+o[a]+"]").prop("disabled",!0);for(a=0;a<daysofweek.length;a++)$j("#"+n+"_"+daysofweek[a].toLowerCase()).prop("disabled",!0);for(a=0;a<i.length;a++)$j("[name="+i[a]+"]").addClass("disabled"),$j("[name="+i[a]+"]").prop("disabled",!0)}else if("true"===t){for(a=0;a<o.length;a++)$j("input[name="+n+"_"+o[a]+"]").removeClass("disabled"),$j("input[name="+n+"_"+o[a]+"]").prop("disabled",!1);for(a=0;a<daysofweek.length;a++)$j("#"+n+"_"+daysofweek[a].toLowerCase()).prop("disabled",!1);for(a=0;a<i.length;a++)$j("[name="+i[a]+"]").removeClass("disabled"),$j("[name="+i[a]+"]").prop("disabled",!1)}}function scheduleModeToggle(t){t.name;t=t.value;"EveryX"===t?(showhide("schfrequency",!0),showhide("schcustom",!1),"hours"===$j("#everyxselect").val()?(showhide("spanxhours",!0),showhide("spanxminutes",!1)):"minutes"===$j("#everyxselect").val()&&(showhide("spanxhours",!1),showhide("spanxminutes",!0))):"Custom"===t&&(showhide("schfrequency",!1),showhide("schcustom",!0))}function getEmailConfFile(){$j.ajax({url:"/ext/connmon/email_config.htm",dataType:"text",cache:!1,error:function(t){setTimeout(getEmailConfFile,1e3)},success:function(data){var emailconfigdata=data.split("\n"),emailconfigdata=emailconfigdata.filter(Boolean);emailconfigdata=emailconfigdata.filter(function(t){return-1===t.indexOf("#")});for(var i=0;i<emailconfigdata.length;i++){let settingname=emailconfigdata[i].split("=")[0].toLowerCase(),settingvalue=emailconfigdata[i].split("=")[1].replace(/(\r\n|\n|\r)/gm,"").replace(/"/g,"");-1===settingname.indexOf("emailpwenc")&&(eval("document.form.email_"+settingname).value=settingvalue)}}})}function getCustomactionInfo(){$j.ajax({url:"/ext/connmon/customactioninfo.htm",dataType:"text",error:function(t){setTimeout(getCustomactionInfo,1e3)},success:function(t){$j("#customaction_details").append("\n"+t)}})}function getCustomactionList(){$j.ajax({url:"/ext/connmon/customactionlist.htm",dataType:"text",cache:!1,error:function(t){setTimeout(getCustomactionList,1e3)},success:function(t){$j("#customaction_details").html(t),getCustomactionInfo()}})}function getEmailpwFile(){$j.ajax({url:"/ext/connmon/password.htm",dataType:"text",cache:!1,error:function(t){document.formScriptActions.action_script.value="start_addon_settings;start_connmoncustomactionlist;start_connmonemailpassword",document.formScriptActions.submit(),setTimeout(getCustomactionList,1e4),setTimeout(getEmailpwFile,1e4)},success:function(t){document.form.email_password.value=t,document.formScriptActions.action_script.value="start_addon_settings;start_connmondeleteemailpassword",document.formScriptActions.submit()}})}function getConfFile(){$j.ajax({url:"/ext/connmon/config.htm",dataType:"text",cache:!1,error:function(t){setTimeout(getConfFile,1e3)},success:function(data){for(var configdata=data.split("\n"),configdata=configdata.filter(Boolean),i=0;i<configdata.length;i++){let settingname=configdata[i].split("=")[0].toLowerCase(),settingvalue=configdata[i].split("=")[1].replace(/(\r\n|\n|\r)/gm,"");if(-1!==settingname.indexOf("pingserver")){var pingserver=settingvalue;document.form.connmon_pingserver.value=pingserver,validateIP(document.form.connmon_pingserver)?(document.form.pingtype.value=0,document.form.connmon_ipaddr.value=pingserver):(document.form.pingtype.value=1,document.form.connmon_domain.value=pingserver),document.form.pingtype.onchange()}else if(-1!==settingname.indexOf("schdays"))if("*"===settingvalue)for(var i2=0;i2<daysofweek.length;i2++)$j("#connmon_"+daysofweek[i2].toLowerCase()).prop("checked",!0);else for(var schdayarray=settingvalue.split(","),i2=0;i2<schdayarray.length;i2++)$j("#connmon_"+schdayarray[i2].toLowerCase()).prop("checked",!0);else if("notifications_pingtest"===settingname)for(var pingtesttypearray=settingvalue.split(","),i2=0;i2<pingtesttypearray.length;i2++)$j("#connmon_pingtest_"+pingtesttypearray[i2].toLowerCase()).prop("checked",!0);else if("notifications_pingthreshold"===settingname)for(var pingthresholdtypearray=settingvalue.split(","),i2=0;i2<pingthresholdtypearray.length;i2++)$j("#connmon_pingthreshold_"+pingthresholdtypearray[i2].toLowerCase()).prop("checked",!0);else if("notifications_jitterthreshold"===settingname)for(var jitterthresholdtypearray=settingvalue.split(","),i2=0;i2<jitterthresholdtypearray.length;i2++)$j("#connmon_jitterthreshold_"+jitterthresholdtypearray[i2].toLowerCase()).prop("checked",!0);else if("notifications_linequalitythreshold"===settingname)for(var linequalitythresholdtypearray=settingvalue.split(","),i2=0;i2<linequalitythresholdtypearray.length;i2++)$j("#connmon_linequalitythreshold_"+linequalitythresholdtypearray[i2].toLowerCase()).prop("checked",!0);else-1!==settingname.indexOf("notifications_email_list")||-1!==settingname.indexOf("notifications_pushover_list")||-1!==settingname.indexOf("notifications_webhook_list")?eval("document.form.connmon_"+settingname).value=settingvalue.replace(/,/g,"\n"):eval("document.form.connmon_"+settingname).value=settingvalue;-1!==settingname.indexOf("automated")&&automaticTestEnableDisable($j("#connmon_auto_"+document.form.connmon_automated.value)[0]),-1!==settingname.indexOf("pingduration")&&(pingtestdur=document.form.connmon_pingduration.value)}-1!==$j("[name=connmon_schhours]").val().indexOf("/")&&0==+$j("[name=connmon_schmins]").val()?(document.form.schedulemode.value="EveryX",document.form.everyxselect.value="hours",document.form.everyxvalue.value=$j("[name=connmon_schhours]").val().split("/")[1]):-1!==$j("[name=connmon_schmins]").val().indexOf("/")&&"*"===$j("[name=connmon_schhours]").val()?(document.form.schedulemode.value="EveryX",document.form.everyxselect.value="minutes",document.form.everyxvalue.value=$j("[name=connmon_schmins]").val().split("/")[1]):document.form.schedulemode.value="Custom",scheduleModeToggle($j("#schmode_"+$j("[name=schedulemode]:checked").val().toLowerCase())[0])}})}function getStatstitleFile(){$j.ajax({url:"/ext/connmon/connstatstext.js",dataType:"script",error:function(t){setTimeout(getStatstitleFile,1e3)},success:function(){setConnmonStatsTitle()}})}function getCronFile(){$j.ajax({url:"/ext/connmon/cron.js",dataType:"text",error:function(t){setTimeout(getCronFile,1e3)},success:function(t){document.form.healthcheckio_cron.value=t}})}function getEmailInfo(){$j.ajax({url:"/ext/connmon/emailinfo.htm",dataType:"text",error:function(t){setTimeout(getEmailInfo,1e3)},success:function(t){$j("#emailinfo").html(t)}})}function getChangelogFile(){$j.ajax({url:"/ext/connmon/changelog.htm",dataType:"text",cache:!1,error:function(t){setTimeout(getChangelogFile,5e3)},success:function(t){$j("#divchangelog").html(t)}})}function getVersionNumber(t){var e;return"local"===t?e=customSettings.connmon_version_local:"server"===t&&(e=customSettings.connmon_version_server),null==e?"N/A":e}function getVersionChangelogFile(){$j.ajax({url:"/ext/connmon/detect_changelog.js",dataType:"script",error:function(t){setTimeout(getVersionChangelogFile,5e3)},success:function(){var t=getVersionNumber("server");$j("#connmon_version_server").html('<a style="color:#FFCC00;text-decoration:underline;" href="javascript:void(0);">Updated version available: '+t+"</a>"),$j("#connmon_version_server").on("mouseover",function(){return overlib(changelog,0,0)}),$j("#connmon_version_server")[0].onmouseout=nd}})}function buildLastXTableNoData(){return'<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="sortTable"><tr><td colspan="6" class="nodata">Data loading...</td></tr></table>'}function buildLastXTable(){var t='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="sortTable">';if("false"===AltLayout){t+='<col style="width:130px;">',t+='<col style="width:200px;">',t+='<col style="width:95px;">',t+='<col style="width:90px;">',t+='<col style="width:90px;">',t+='<col style="width:110px;">',t+='<thead class="sortTableHeader">',t+="<tr>",t+='<th class="sortable" onclick="sortTable(this.innerHTML.replace(/ \\(.*\\)/,\'\'))">Time</th>',t+='<th class="sortable" onclick="sortTable(this.innerHTML.replace(/ \\(.*\\)/,\'\'))">Target</th>',t+='<th class="sortable" onclick="sortTable(this.innerHTML.replace(/ \\(.*\\)/,\'\'))">Duration (s)</th>',t+='<th class="sortable" onclick="sortTable(this.innerHTML.replace(/ \\(.*\\)/,\'\'))">Ping (ms)</th>',t+='<th class="sortable" onclick="sortTable(this.innerHTML.replace(/ \\(.*\\)/,\'\'))">Jitter (ms)</th>',t+="<th class=\"sortable\" onclick=\"sortTable(this.innerHTML.replace(/ \\(.*\\)/,'').replace(' ',''))\">Line Quality (%)</th>",t+="</tr>",t+="</thead>",t+='<tbody class="sortTableContent">';for(var e=0;e<arraysortlistlines.length;e++)t+='<tr class="sortRow">',t+="<td>"+arraysortlistlines[e].Time+"</td>",t+="<td>"+arraysortlistlines[e].Target+"</td>",t+="<td>"+arraysortlistlines[e].Duration+"</td>",t+="<td>"+arraysortlistlines[e].Ping+"</td>",t+="<td>"+arraysortlistlines[e].Jitter+"</td>",t+="<td>"+arraysortlistlines[e].LineQuality+"</td>",t+="</tr>"}else{t+='<col style="width:130px;">',t+='<col style="width:90px;">',t+='<col style="width:90px;">',t+='<col style="width:110px;">',t+='<col style="width:200px;">',t+='<col style="width:95px;">',t+='<thead class="sortTableHeader">',t+="<tr>",t+='<th class="sortable" onclick="sortTable(this.innerHTML.replace(/ \\(.*\\)/,\'\'))">Time</th>',t+='<th class="sortable" onclick="sortTable(this.innerHTML.replace(/ \\(.*\\)/,\'\'))">Ping (ms)</th>',t+='<th class="sortable" onclick="sortTable(this.innerHTML.replace(/ \\(.*\\)/,\'\'))">Jitter (ms)</th>',t+="<th class=\"sortable\" onclick=\"sortTable(this.innerHTML.replace(/ \\(.*\\)/,'').replace(' ',''))\">Line Quality (%)</th>",t+='<th class="sortable" onclick="sortTable(this.innerHTML.replace(/ \\(.*\\)/,\'\'))">Target</th>',t+='<th class="sortable" onclick="sortTable(this.innerHTML.replace(/ \\(.*\\)/,\'\'))">Duration (s)</th>',t+="</tr>",t+="</thead>",t+='<tbody class="sortTableContent">';for(e=0;e<arraysortlistlines.length;e++)t+='<tr class="sortRow">',t+="<td>"+arraysortlistlines[e].Time+"</td>",t+="<td>"+arraysortlistlines[e].Ping+"</td>",t+="<td>"+arraysortlistlines[e].Jitter+"</td>",t+="<td>"+arraysortlistlines[e].LineQuality+"</td>",t+="<td>"+arraysortlistlines[e].Target+"</td>",t+="<td>"+arraysortlistlines[e].Duration+"</td>",t+="</tr>"}return t+="</tbody>",t+="</table>"}function scriptUpdateLayout(){var t=getVersionNumber("local"),e=getVersionNumber("server");$j("#connmon_version_local").text(t),t!==e&&"N/A"!==e&&(-1===e.indexOf("hotfix")?getVersionChangelogFile():$j("#connmon_version_server").text(e),showhide("connmon_version_server",!0),showhide("btnChkUpdate",!1),showhide("btnDoUpdate",!0))}function initial(){setCurrentPage(),loadCustomSettings(),show_menu(),document.formScriptActions.action_script.value="start_addon_settings;start_connmoncustomactionlist;start_connmonemailpassword",document.formScriptActions.submit(),setTimeout(getCustomactionList,1e4),setTimeout(getEmailpwFile,1e4),getConfFile(),getEmailConfFile(),getStatstitleFile(),getEmailInfo(),getCronFile(),getChangelogFile(),$j("#alternatelayout").prop("checked","false"!==AltLayout),$j("#sortTableContainer").empty(),$j("#sortTableContainer").append(buildLastXTableNoData()),d3.csv("/ext/connmon/csv/CompleteResults.htm").then(function(t){parseCSVExport(t)}).catch(function(){errorCSVExport()}),$j("#Time_Format").val(getCookie("Time_Format","number")),redrawAllCharts(),scriptUpdateLayout();var t=getCookie("StartTab","number");0===t&&(t=1),$j("#starttab").val(t),jyNavigate(t,"",5),jyNavigate(1,"Chart",3),jyNavigate(1,"NotificationType",4),jyNavigate(1,"NotificationMethod",6)}function setStartTab(t){setCookie("StartTab",$j(t).val())}function passChecked(t,e){switchType(t,e.checked,!0)}function toggleAlternateLayout(t){setCookie("AltLayout",AltLayout=t.checked.toString()),sortTable(sortname+" "+sortdir.replace("desc","↑").replace("asc","↓").trim())}function statusUpdate(){$j.ajax({url:"/ext/connmon/detect_update.js",dataType:"script",error:function(t){setTimeout(statusUpdate,1e3)},success:function(){"InProgress"===updatestatus?setTimeout(statusUpdate,1e3):(iziToast.destroy(),document.getElementById("imgChkUpdate").style.display="none",showhide("connmon_version_server",!0),"None"!==updatestatus?(customSettings.connmon_version_server=updatestatus,-1===updatestatus.indexOf("hotfix")?getVersionChangelogFile():$j("#connmon_version_server").text("Updated version available: "+updatestatus),iziToast.warning({message:"New version available!"}),showhide("btnChkUpdate",!1),showhide("btnDoUpdate",!0)):(iziToast.info({message:"No updates available"}),$j("#connmon_version_server").text("No updates available"),showhide("btnChkUpdate",!0),showhide("btnDoUpdate",!1)))}})}function checkUpdate(){document.formScriptActions.action_script.value="start_addon_settings;start_connmoncheckupdate",document.formScriptActions.submit(),showhide("btnChkUpdate",!1),document.getElementById("imgChkUpdate").style.display="",iziToast.info({message:"Checking for updates...",timeout:!1}),setTimeout(statusUpdate,2e3)}function doUpdate(){document.form.action_script.value="start_connmondoupdate",document.form.action_wait.value=10,showLoading(),document.form.submit()}function postConnTest(){currentNoCharts=0,$j("#Time_Format").val(getCookie("Time_Format","number")),getStatstitleFile(),setTimeout(redrawAllCharts,3e3)}function saveStatus(e){$j.ajax({url:"/ext/connmon/detect_save.js",dataType:"script",error:function(t){setTimeout(saveStatus,1e3,e)},success:function(){"InProgress"===savestatus?setTimeout(saveStatus,1e3,e):(showhide("imgSave"+e,!1),"Success"===savestatus&&(iziToast.destroy(),iziToast.success({message:"Save successful"}),showhide("btnSave"+e,!0),loadCustomSettings(),"Navigate3"===e&&postConnTest()))}})}function saveConfig(t){switch(t){case"Navigate3":if(!validateAll())return!1;var e;(n=$j("#"+t).find("[disabled]")).prop("disabled",!1),0==+document.form.pingtype.value?document.form.connmon_pingserver.value=document.form.connmon_ipaddr.value:1==+document.form.pingtype.value&&(document.form.connmon_pingserver.value=document.form.connmon_domain.value),"EveryX"===document.form.schedulemode.value&&("hours"===document.form.everyxselect.value?(e=+document.form.everyxvalue.value,document.form.connmon_schmins.value=0,document.form.connmon_schhours.value=24===e?0:"*/"+e):"minutes"===document.form.everyxselect.value&&(document.form.connmon_schhours.value="*",e=+document.form.everyxvalue.value,document.form.connmon_schmins.value="*/"+e)),document.getElementById("amng_custom").value=JSON.stringify($j("#"+t).find("input,select,textarea").serializeObject()),document.formScriptActions.action_script.value="start_addon_settings;start_connmonconfig",document.formScriptActions.submit(),n.prop("disabled",!0),showhide("btnSave"+t,!1),showhide("imgSave"+t,!0),iziToast.info({message:"Saving...",timeout:!1}),setTimeout(saveStatus,5e3,t);break;case"NotificationMethodNavigate1Config":(n=$j("#"+t).find("[disabled]")).prop("disabled",!1),document.getElementById("amng_custom").value=JSON.stringify($j("#table_connmonemailconfig").find("input,select,textarea").serializeObject()),document.formScriptActions.action_script.value="start_addon_settings;start_connmonconfig",document.formScriptActions.submit(),n.prop("disabled",!0),showhide("btnSave"+t,!1),showhide("imgSave"+t,!0),iziToast.info({message:"Saving...",timeout:!1}),setTimeout(saveStatus,5e3,t);break;case"NotificationMethodNavigate1Email":(n=$j("#"+t).find("[disabled]")).prop("disabled",!1),document.getElementById("amng_custom").value=JSON.stringify($j("#table_emailconfig").find("input,select,textarea").serializeObjectEmail()),document.formScriptActions.action_script.value="start_addon_settings;start_connmonemailconfig",document.formScriptActions.submit(),n.prop("disabled",!0),showhide("btnSave"+t,!1),showhide("imgSave"+t,!0),iziToast.info({message:"Saving...",timeout:!1}),setTimeout(saveStatus,5e3,t);break;default:var n;(n=$j("#"+t).find("[disabled]")).prop("disabled",!1),document.getElementById("amng_custom").value=JSON.stringify($j("#"+t).find("input,select,textarea").serializeObject()),document.formScriptActions.action_script.value="start_addon_settings;start_connmonconfig",document.formScriptActions.submit(),n.prop("disabled",!0),showhide("btnSave"+t,!1),showhide("imgSave"+t,!0),iziToast.info({message:"Saving...",timeout:!1}),setTimeout(saveStatus,5e3,t)}}function getConntestResultFile(){$j.ajax({url:"/ext/connmon/ping-result.htm",dataType:"text",cache:!1,error:function(t){setTimeout(getConntestResultFile,500)},success:function(t){t=t.trim().split("\n").join("\n"),$j("#conntest_output").html(t),document.getElementById("conntest_output").parentElement.parentElement.style.display=""}})}function testStatus(e){$j.ajax({url:"/ext/connmon/detect_test.js",dataType:"script",error:function(t){setTimeout(testStatus,1e3,e)},success:function(){"InProgress"===teststatus?setTimeout(testStatus,1e3,e):(showhide("img"+e,!1),iziToast.destroy(),showhide("btn"+e,!0),"Success"===teststatus?iziToast.success({message:"Test successful"}):iziToast.error({message:"Test failed - please check configuration"}))}})}function testNotification(t){confirm("If you have made any changes, you will need to save them first. Do you want to continue?")&&(showhide("btn"+t,!1),document.formScriptActions.action_script.value="start_addon_settings;start_connmon"+t,document.formScriptActions.submit(),showhide("img"+t,!0),setTimeout(testStatus,1e3,t),iziToast.info({message:"Running test...",timeout:!1}))}function everyXToggle(t){t.name;t=t.value;"hours"===t?(showhide("spanxhours",!0),showhide("spanxminutes",!1)):"minutes"===t&&(showhide("spanxhours",!1),showhide("spanxminutes",!0)),validateScheduleValue($j("[name=everyxvalue]")[0])}$j(document).keydown(function(t){keyHandler(t)}),$j(document).keyup(function(t){$j(document).keydown(function(t){keyHandler(t)})}),$j.fn.serializeObject=function(){var s=customSettings,t=this.serializeArray();return $j.each(t,function(){var t,e,n,o,i,a;void 0!==s[this.name]&&-1!==this.name.indexOf("connmon")&&-1===this.name.indexOf("version")&&-1===this.name.indexOf("ipaddr")&&-1===this.name.indexOf("domain")&&-1===this.name.indexOf("schdays")&&-1===this.name.indexOf("pushover_list")&&-1===this.name.indexOf("pushover_list")&&-1===this.name.indexOf("webhook_list")&&"connmon_notifications_pingtest"!==this.name&&"connmon_notifications_pingthreshold"!==this.name&&"connmon_notifications_jitterthreshold"!==this.name&&"connmon_notifications_linequalitythreshold"!==this.name?(s[this.name].push||(s[this.name]=[s[this.name]]),s[this.name].push(this.value||"")):-1!==this.name.indexOf("connmon")&&-1===this.name.indexOf("version")&&-1===this.name.indexOf("ipaddr")&&-1===this.name.indexOf("domain")&&-1===this.name.indexOf("schdays")&&-1===this.name.indexOf("pushover_list")&&-1===this.name.indexOf("pushover_list")&&-1===this.name.indexOf("webhook_list")&&"connmon_notifications_pingtest"!==this.name&&"connmon_notifications_pingthreshold"!==this.name&&"connmon_notifications_jitterthreshold"!==this.name&&"connmon_notifications_linequalitythreshold"!==this.name&&(s[this.name]=this.value||""),-1!==this.name.indexOf("schdays")&&(t=[],$j.each($j('input[name="connmon_schdays"]:checked'),function(){t.push($j(this).val())}),"Mon,Tues,Wed,Thurs,Fri,Sat,Sun"===(e=t.join(","))&&(e="*"),s.connmon_schdays=e),"connmon_notifications_pingtest"===this.name&&(n=[],$j.each($j('input[name="connmon_notifications_pingtest"]:checked'),function(){n.push($j(this).val())}),s.connmon_notifications_pingtest=n.join(",")),"connmon_notifications_pingthreshold"===this.name&&(o=[],$j.each($j('input[name="connmon_notifications_pingthreshold"]:checked'),function(){o.push($j(this).val())}),s.connmon_notifications_pingthreshold=o.join(",")),"connmon_notifications_jitterthreshold"===this.name&&(i=[],$j.each($j('input[name="connmon_notifications_jitterthreshold"]:checked'),function(){i.push($j(this).val())}),s.connmon_notifications_jitterthreshold=i.join(",")),"connmon_notifications_linequalitythreshold"===this.name&&(a=[],$j.each($j('input[name="connmon_notifications_linequalitythreshold"]:checked'),function(){a.push($j(this).val())}),s.connmon_notifications_linequalitythreshold=a.join(",")),-1!==this.name.indexOf("connmon_notifications_email_list")&&(s.connmon_notifications_email_list=document.getElementById("connmon_notifications_email_list").value.replace(/\n/g,"||||")),-1!==this.name.indexOf("connmon_notifications_pushover_list")&&(s.connmon_notifications_pushover_list=document.getElementById("connmon_notifications_pushover_list").value.replace(/\n/g,"||||")),-1!==this.name.indexOf("connmon_notifications_webhook_list")&&(s.connmon_notifications_webhook_list=document.getElementById("connmon_notifications_webhook_list").value.replace(/\n/g,"||||"))}),$j.each(this,function(){var t,e,n,o,i;-1!==this.name.indexOf("schdays")&&(t=[],$j.each($j('input[name="connmon_schdays"]:checked'),function(){t.push($j(this).val())}),0===t.length&&(s.connmon_schdays="*")),"connmon_notifications_pingtest"===this.name&&(e=[],$j.each($j('input[name="connmon_notifications_pingtest"]:checked'),function(){e.push($j(this).val())}),0===e.length&&(s.connmon_notifications_pingtest="None")),"connmon_notifications_pingthreshold"===this.name&&(n=[],$j.each($j('input[name="connmon_notifications_pingthreshold"]:checked'),function(){n.push($j(this).val())}),0===n.length&&(s.connmon_notifications_pingthreshold="None")),"connmon_notifications_jitterthreshold"===this.name&&(o=[],$j.each($j('input[name="connmon_notifications_jitterthreshold"]:checked'),function(){o.push($j(this).val())}),0===o.length&&(s.connmon_notifications_jitterthreshold="None")),"connmon_notifications_linequalitythreshold"===this.name&&(i=[],$j.each($j('input[name="connmon_notifications_linequalitythreshold"]:checked'),function(){i.push($j(this).val())}),0===i.length&&(s.connmon_notifications_linequalitythreshold="None"))}),s},$j.fn.serializeObjectEmail=function(){var t=customSettings,e=this.serializeArray();return $j.each(e,function(){void 0!==t[this.name]&&-1!==this.name.indexOf("email_")&&-1===this.name.indexOf("show_pass")?(t[this.name].push||(t[this.name]=[t[this.name]]),t[this.name].push(this.value||"")):-1!==this.name.indexOf("email_")&&-1===this.name.indexOf("show_pass")&&(t[this.name]=this.value||"")}),t};var pingcount=2;function updateConntest(){pingcount++,$j.ajax({url:"/ext/connmon/detect_connmon.js",dataType:"script",error:function(t){},success:function(){"InProgress"===connmonstatus?(showhide("imgConnTest",!0),showhide("conntest_text",!0),$j("#conntest_text").html("Ping test in progress - "+pingcount+"s elapsed")):"GenerateCSV"===connmonstatus?$j("#conntest_text").html("Retrieving data for charts..."):"Done"===connmonstatus?(clearInterval(myinterval),!1===intervalclear&&(intervalclear=!0,pingcount=2,getConntestResultFile(),$j("#conntest_text").html("Refreshing charts..."),postConnTest())):"LOCKED"===connmonstatus?(pingcount=2,clearInterval(myinterval),showhide("imgConnTest",!1),$j("#conntest_text").html("Scheduled ping test already running!"),showhide("conntest_text",!0),showhide("btnRunPingtest",!0),document.getElementById("conntest_output").parentElement.parentElement.style.display="none",iziToast.destroy(),iziToast.error({message:"Ping test failed - scheduled ping test already running!"})):"InvalidServer"===connmonstatus&&(pingcount=2,clearInterval(myinterval),showhide("imgConnTest",!1),$j("#conntest_text").html("Specified ping server is not valid"),showhide("conntest_text",!0),showhide("btnRunPingtest",!0),document.getElementById("conntest_output").parentElement.parentElement.style.display="none",iziToast.destroy(),iziToast.error({message:"Ping test failed - Specified ping server is not valid"}))}})}function startConnTestInterval(){pingtestrunning=!(intervalclear=!1),myinterval=setInterval(updateConntest,1e3)}function runPingTest(){showhide("btnRunPingtest",!1),$j("#conntest_output").html(""),document.getElementById("conntest_output").parentElement.parentElement.style.display="none",document.formScriptActions.action_script.value="start_addon_settings;start_connmon",document.formScriptActions.submit(),showhide("imgConnTest",!0),showhide("conntest_text",!1),setTimeout(startConnTestInterval,5e3),iziToast.info({message:"Ping test started",timeout:!1})}function changeAllCharts(t){value=+t.value,name=t.id.substring(0,t.id.indexOf("_")),setCookie(t.id,value);for(var e=0;e<metriclist.length;e++)drawChart(metriclist[e],titlelist[e],measureunitlist[e],bordercolourlist[e],backgroundcolourlist[e])}function changeChart(t){value=+t.value,name=t.id.substring(0,t.id.indexOf("_")),setCookie(t.id,value),"Ping"===name?drawChart("Ping",titlelist[0],measureunitlist[0],bordercolourlist[0],backgroundcolourlist[0]):"Jitter"===name?drawChart("Jitter",titlelist[1],measureunitlist[1],bordercolourlist[1],backgroundcolourlist[1]):"LineQuality"===name&&drawChart("LineQuality",titlelist[2],measureunitlist[2],bordercolourlist[2],backgroundcolourlist[2])}
	</script>
</head>
<body onload="initial();" onunload="return unload_body();">
	<div id="TopBanner"></div>
	<div id="Loading" class="popup_bg"></div>
	<iframe name="hidden_frame" id="hidden_frame" src="about:blank" width="0" height="0" frameborder="0"></iframe>
	<form method="post" name="formScriptActions" action="/start_apply.htm" target="hidden_frame">
		<input type="hidden" name="productid" value="<% nvram_get(" productid"); %>">
		<input type="hidden" name="current_page" value="">
		<input type="hidden" name="next_page" value="">
		<input type="hidden" name="action_mode" value="apply">
		<input type="hidden" name="action_script" value="">
		<input type="hidden" name="action_wait" value="0">
		<input type="hidden" name="amng_custom" id="amng_custom" value="">
	</form>
	<form method="post" name="form" id="ruleForm" action="/start_apply.htm" target="hidden_frame">
		<input type="hidden" name="current_page" value="">
		<input type="hidden" name="next_page" value="">
		<input type="hidden" name="modified" value="0">
		<input type="hidden" name="action_mode" value="apply">
		<input type="hidden" name="action_script" value="start_connmon">
		<input type="hidden" name="action_wait" value="45">
		<input type="hidden" name="first_time" value="">
		<input type="hidden" name="SystemCmd" value="">
		<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get(" preferred_lang"); %>">
		<input type="hidden" name="firmver" value="<% nvram_get(" firmver"); %>">
		<table class="content" align="center" cellpadding="0" cellspacing="0">
			<tr>
				<td width="17">&nbsp;</td>
				<td valign="top" width="202">
					<div id="mainMenu"></div>
					<div id="subMenu"></div>
				</td>
				<td valign="top">
					<div id="tabMenu" class="submenuBlock"></div>
					<table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
						<tr>
							<td valign="top">
								<table width="760px" border="0" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3"
									class="FormTitle" id="FormTitle">
									<tbody>
										<tr bgcolor="#4D595D">
											<td valign="top">
												<div>&nbsp;</div>
												<div class="formfonttitle" id="scripttitle" style="text-align:center;">
													connmon</div>
												<div id="statstitle" style="text-align:center;">Stats last updated:
												</div>
												<div style="margin:10px 0 10px 5px;" class="splitLine"></div>
												<div class="formfontdesc">connmon is an internet connection monitoring
													tool for AsusWRT Merlin with charts for daily, weekly and monthly
													summaries.</div>
												<div style="margin:10px 0 10px 5px;" class="splitLine"></div>
												<div style="text-align:center;">
													<button type="button" class="button_gen navbutton"
														onclick="jyNavigate(1,'',5);" id="btnNavigate1">Ping
														Test<br />and<br />Results</button>
													<button type="button" class="button_gen navbutton"
														onclick="jyNavigate(2,'',5);" id="btnNavigate2">Charts</button>
													<button type="button" class="button_gen navbutton"
														onclick="jyNavigate(3,'',5);"
														id="btnNavigate3">Utilities<br />and<br />Configuration</button>
													<button type="button" class="button_gen navbutton"
														onclick="jyNavigate(4,'',5);"
														id="btnNavigate4">Notifications<br />and<br />Integrations</button>
													<button type="button" class="button_gen navbutton"
														onclick="jyNavigate(5,'',5);"
														id="btnNavigate5">Changelog</button>
												</div>
												<div style="margin:10px 0 10px 5px;" class="splitLine"></div>
												<div id="Navigate1" style="display:none;">
													<table width="100%" border="1" align="center" cellpadding="4"
														cellspacing="0" bordercolor="#6b8fa3" class="FormTable"
														style="border:0;" id="table_manualpingtest">
														<thead class="collapsible-jquery" id="thead_manualpingtest">
															<tr>
																<td colspan="2">Manual ping test</td>
															</tr>
														</thead>
														<tr>
															<th width="20%">Ping test</th>
															<td>
																<input type="button" onclick="runPingTest();"
																	value="Run ping test" class="button_gen"
																	name="btnRunPingtest" id="btnRunPingtest">
																<img id="imgConnTest"
																	style="display:none;vertical-align:middle;"
																	src="images/InternetScan.gif" />
																&nbsp;&nbsp;&nbsp;
																<span id="conntest_text" style="display:none;"></span>
															</td>
														</tr>
														<tr style="display:none;">
															<td colspan="2" style="padding:0;">
																<textarea cols="63" rows="4" wrap="off"
																	readonly="readonly" id="conntest_output"
																	class="textarea_log_table"
																	style="border:0;resize:none;overflow-y:auto;overflow-x:hidden;">Ping test output</textarea>
															</td>
														</tr>
													</table>
													<div style="margin:10px 0 10px 5px;" class="splitLine"></div>
													<table width="100%" border="1" align="center" cellpadding="4"
														cellspacing="0" bordercolor="#6b8fa3" class="FormTable"
														id="resulttable_pings">
														<thead class="collapsible-jquery" id="resultthead_pings">
															<tr>
																<td colspan="2">Latest ping test results</td>
															</tr>
														</thead>
														<tr class="even">
															<th width="35%">Move target and duration columns to end of
																table?</th>
															<td width="65%">
																<label style="color:#FFCC00;display:block;"><input
																		type="checkbox" id="alternatelayout"
																		onclick="toggleAlternateLayout(this)"
																		style="padding:0;margin:0;vertical-align:middle;position:relative;top:-1px;" /></label>
															</td>
														</tr>
														<tr>
															<td colspan="2"></td>
														</tr>
														<tr>
															<td colspan="2" align="center" style="padding:0;">
																<div id="sortTableContainer" class="sortTableContainer">
																</div>
															</td>
														</tr>
													</table>
												</div>
												<div id="Navigate2" style="display:none;">
													<table width="100%" border="1" align="center" cellpadding="4"
														cellspacing="0" bordercolor="#6b8fa3" class="FormTable"
														id="table_charts">
														<thead class="collapsible-jquery" id="thead_charts">
															<tr>
																<td>Charts</td>
															</tr>
														</thead>
														<tr>
															<td align="center" style="padding:0;">
																<button type="button" class="button_gen chartnavbutton"
																	onclick="jyNavigate(1,'Chart',3);"
																	id="btnChartNavigate1">Ping</button>
																<button type="button" class="button_gen chartnavbutton"
																	onclick="jyNavigate(2,'Chart',3);"
																	id="btnChartNavigate2">Jitter</button>
																<button type="button" class="button_gen chartnavbutton"
																	onclick="jyNavigate(3,'Chart',3);"
																	id="btnChartNavigate3">Quality</button>
																<button type="button" class="button_gen chartnavbutton"
																	onclick="jyNavigate(0,'Chart',3);"
																	id="btnChartNavigate0">All</button>
															</td>
														</tr>
													</table>
													<div id="ChartNavigate1">
														<div style="line-height:10px;">&nbsp;</div>
														<table width="100%" border="1" align="center" cellpadding="4"
															cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
															<thead class="collapsible-jquery" id="chart_ping">
																<tr>
																	<td colspan="2">Ping</td>
																</tr>
															</thead>
															<tr class="even">
																<th width="40%">Data interval</th>
																<td>
																	<select style="width:150px" class="input_option"
																		onchange="changeChart(this);changePeriod(this);"
																		id="Ping_Interval">
																		<option value="0">Raw</option>
																		<option value="1">Hours</option>
																		<option value="2">Days</option>
																	</select>
																</td>
															</tr>
															<tr class="even">
																<th width="40%">Period to display</th>
																<td>
																	<select style="width:150px" class="input_option"
																		onchange="changeChart(this)" id="Ping_Period">
																		<option value="0">Last 24 hours</option>
																		<option value="1">Last 7 days</option>
																		<option value="2">Last 30 days</option>
																	</select>
																</td>
															</tr>
															<tr class="even">
																<th width="40%">Scale type</th>
																<td>
																	<select style="width:150px" class="input_option"
																		onchange="changeChart(this)" id="Ping_Scale">
																		<option value="0">Linear</option>
																		<option value="1">Logarithmic</option>
																	</select>
																</td>
															</tr>
															<tr>
																<td colspan="2" align="center" style="padding:0;">
																	<div
																		style="background-color:#2f3e44;border-radius:10px;width:730px;height:500px;padding-left:5px;">
																		<canvas id="divLineChart_Ping" height="500" />
																	</div>
																</td>
															</tr>
														</table>
													</div>
													<div id="ChartNavigate2">
														<div style="line-height:10px;">&nbsp;</div>
														<table width="100%" border="1" align="center" cellpadding="4"
															cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
															<thead class="collapsible-jquery" id="chart_jitter">
																<tr>
																	<td colspan="2">Jitter</td>
																</tr>
															</thead>
															<tr class="even">
																<th width="40%">Data interval</th>
																<td>
																	<select style="width:150px" class="input_option"
																		onchange="changeChart(this);changePeriod(this);"
																		id="Jitter_Interval">
																		<option value="0">Raw</option>
																		<option value="1">Hours</option>
																		<option value="2">Days</option>
																	</select>
																</td>
															</tr>
															<tr class="even">
																<th width="40%">Period to display</th>
																<td>
																	<select style="width:150px" class="input_option"
																		onchange="changeChart(this)" id="Jitter_Period">
																		<option value="0">Last 24 hours</option>
																		<option value="1">Last 7 days</option>
																		<option value="2">Last 30 days</option>
																	</select>
																</td>
															</tr>
															<tr class="even">
																<th width="40%">Scale type</th>
																<td>
																	<select style="width:150px" class="input_option"
																		onchange="changeChart(this)" id="Jitter_Scale">
																		<option value="0">Linear</option>
																		<option value="1">Logarithmic</option>
																	</select>
																</td>
															</tr>
															<tr>
																<td colspan="2" align="center" style="padding:0;">
																	<div
																		style="background-color:#2f3e44;border-radius:10px;width:730px;height:500px;padding-left:5px;">
																		<canvas id="divLineChart_Jitter" height="500" />
																	</div>
																</td>
															</tr>
														</table>
													</div>
													<div id="ChartNavigate3">
														<div style="line-height:10px;">&nbsp;</div>
														<table width="100%" border="1" align="center" cellpadding="4"
															cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
															<thead class="collapsible-jquery" id="chart_linequality">
																<tr>
																	<td colspan="2">Quality</td>
																</tr>
															</thead>
															<tr class="even">
																<th width="40%">Data interval</th>
																<td>
																	<select style="width:150px" class="input_option"
																		onchange="changeChart(this);changePeriod(this);"
																		id="LineQuality_Interval">
																		<option value="0">Raw</option>
																		<option value="1">Hours</option>
																		<option value="2">Days</option>
																	</select>
																</td>
															</tr>
															<tr class="even">
																<th width="40%">Period to display</th>
																<td>
																	<select style="width:150px" class="input_option"
																		onchange="changeChart(this)"
																		id="LineQuality_Period">
																		<option value="0">Last 24 hours</option>
																		<option value="1">Last 7 days</option>
																		<option value="2">Last 30 days</option>
																	</select>
																</td>
															</tr>
															<tr class="even">
																<th width="40%">Scale type</th>
																<td>
																	<select style="width:150px" class="input_option"
																		onchange="changeChart(this)"
																		id="LineQuality_Scale">
																		<option value="0">Linear</option>
																		<option value="1">Logarithmic</option>
																	</select>
																</td>
															</tr>
															<tr>
																<td colspan="2" align="center" style="padding:0;">
																	<div
																		style="background-color:#2f3e44;border-radius:10px;width:730px;height:500px;padding-left:5px;">
																		<canvas id="divLineChart_LineQuality"
																			height="500" />
																	</div>
																</td>
															</tr>
														</table>
													</div>
													<div style="line-height:10px;">&nbsp;</div>
													<table width="100%" border="1" align="center" cellpadding="2"
														cellspacing="0" bordercolor="#6b8fa3" class="FormTable"
														style="border:0;" id="table_buttons2">
														<thead class="collapsible-jquery" id="charttools">
															<tr>
																<td colspan="2">Chart Display Options</td>
															</tr>
														</thead>
														<tr>
															<th width="20%"><span
																	style="color:#fff;background:#2f3a3e;">Time
																	format</span><br /><span
																	style="color:#ffcc00;background:#2f3a3e;">(for
																	tooltips and Last 24h chart axis)</span></th>
															<td>
																<select style="width:100px" class="input_option"
																	onchange="changeAllCharts(this)" id="Time_Format">
																	<option value="0">24h</option>
																	<option value="1">12h</option>
																</select>
															</td>
														</tr>
														<tr class="apply_gen" valign="top">
															<td style="background-color:rgb(77,89,93);" colspan="2">
																<input type="button" onclick="toggleDragZoom(this);"
																	value="Drag Zoom On" class="button_gen"
																	name="btnDragZoom">
																&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
																<input type="button" onclick="resetZoom();"
																	value="Reset Zoom" class="button_gen"
																	name="btnresetZoom">
																&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
																<input type="button" onclick="toggleLines();"
																	value="Toggle Lines" class="button_gen"
																	name="btntoggleLines">
																&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
																<input type="button" onclick="toggleFill();"
																	value="Toggle Fill" class="button_gen"
																	name="btntoggleFill">
															</td>
														</tr>
													</table>
												</div>
												<div id="Navigate3" style="display:none;">
													<table width="100%" border="1" align="center" cellpadding="2"
														cellspacing="0" bordercolor="#6b8fa3"
														class="FormTable SettingsTable" style="border:0;"
														id="table_buttons">
														<thead class="collapsible-jquery" id="scripttools">
															<tr>
																<td colspan="2">Utilities</td>
															</tr>
														</thead>
														<tr>
															<td class="settingname">Version information</td>
															<td class="settingvalue">
																<span id="connmon_version_local"
																	style="color:#fff;"></span>
																&nbsp;&nbsp;&nbsp;
																<span id="connmon_version_server"
																	style="display:none;">Update version</span>
																&nbsp;&nbsp;&nbsp;
																<input type="button" class="button_gen"
																	onclick="checkUpdate(true);" value="Check"
																	id="btnChkUpdate">
																<img id="imgChkUpdate"
																	style="display:none;vertical-align:middle;"
																	src="images/InternetScan.gif" />
																<input type="button" class="button_gen"
																	onclick="doUpdate();" value="Update"
																	id="btnDoUpdate" style="display:none;">
																&nbsp;&nbsp;&nbsp;
															</td>
														</tr>
														<tr>
															<td class="settingname">Export</td>
															<td class="settingvalue">
																<a id="aExport" href="" download="connmon.csv"><input
																		type="button" value="Export to CSV"
																		class="button_gen" name="btnExport"></a>
															</td>
														</tr>
														<tr class="even">
															<td class="settingname">Starting tab for WebUI<br /><span
																	class="settingname">(automatically saves a cookie
																	when you change selected option)</span></td>
															<td class="settingvalue">
																<select style="width:300px" class="input_option"
																	onchange="setStartTab(this)" id="starttab">
																	<option value="1">Ping Test and Results</option>
																	<option value="2">Charts</option>
																	<option value="3">Utilities and Configuration
																	</option>
																	<option value="4">Notifications and Integrations
																	</option>
																	<option value="5">Changelog</option>
																</select>
															</td>
														</tr>
													</table>
													<div style="margin:10px 0 10px 5px;" class="splitLine"></div>
													<table width="100%" border="1" align="center" cellpadding="2"
														cellspacing="0" bordercolor="#6b8fa3"
														class="FormTable SettingsTable" id="table_generalconfig">
														<thead class="collapsible-jquery" id="generalconfig">
															<tr>
																<td colspan="2">Configuration</td>
															</tr>
														</thead>
														<tr class="even">
															<td class="settingname">Ping destination type</td>
															<td class="settingvalue">
																<select style="width:125px" class="input_option"
																	onchange="changePingType(this)" id="pingtype">
																	<option value="0">IP Address</option>
																	<option value="1">Domain</option>
																</select>
																<input type="hidden" name="connmon_pingserver"
																	id="connmon_pingserver" value="">
															</td>
														</tr>
														<tr class="even" id="rowip">
															<td class="settingname">IP Address</td>
															<td class="settingvalue">
																<input autocomplete="off" type="text" maxlength="15"
																	class="input_15_table removespacing"
																	name="connmon_ipaddr" value="8.8.8.8"
																	onkeypress="return validator.isIPAddr(this,event)"
																	onblur="validateIP(this)" onkeyup="validateIP(this)"
																	data-lpignore="true" />
															</td>
														</tr>
														<tr class="even" id="rowdomain">
															<td class="settingname">Domain</td>
															<td class="settingvalue">
																<input autocorrect="off" autocapitalize="off"
																	type="text" maxlength="255"
																	style="text-align:left;padding-left:5px;"
																	class="input_32_table removespacing"
																	name="connmon_domain" value="google.co.uk"
																	onkeypress="return validator.isString(this,event);"
																	onblur="validateDomain(this)"
																	onkeyup="validateDomain(this)"
																	data-lpignore="true" />
															</td>
														</tr>
														<tr class="even" id="rowpingdur">
															<td class="settingname">Ping test duration</td>
															<td class="settingvalue">
																<input autocomplete="off" type="text" maxlength="2"
																	class="input_3_table removespacing"
																	name="connmon_pingduration" value="60"
																	onkeypress="return validator.isNumber(this,event)"
																	onblur="validateNumberSetting(this,60,10);formatNumberSetting(this)"
																	onkeyup="validateNumberSetting(this,60,10)"
																	data-lpignore="true" />
																&nbsp;seconds <span style="color:#FFCC00;">(between 10
																	and 60, default: 60)</span>
															</td>
														</tr>
														<tr class="even" id="rowlastxresults">
															<td class="settingname">Last X results to display</td>
															<td class="settingvalue">
																<input autocomplete="off" type="text" maxlength="3"
																	class="input_6_table removespacing"
																	name="connmon_lastxresults" value="10"
																	onkeypress="return validator.isNumber(this,event)"
																	onblur="validateNumberSetting(this,100,1);formatNumberSetting(this)"
																	onkeyup="validateNumberSetting(this,100,1)"
																	data-lpignore="true" />
																&nbsp;results <span style="color:#FFCC00;">(between 1
																	and 100, default: 10)</span>
															</td>
														</tr>
														<tr class="even" id="rowdaystokeep">
															<td class="settingname">Number of days of data to keep</td>
															<td class="settingvalue">
																<input autocomplete="off" type="text" maxlength="3"
																	class="input_6_table removespacing"
																	name="connmon_daystokeep" value="30"
																	onkeypress="return validator.isNumber(this,event)"
																	onblur="validateNumberSetting(this,365,30);formatNumberSetting(this)"
																	onkeyup="validateNumberSetting(this,365,30)"
																	data-lpignore="true" />
																&nbsp;days <span style="color:#FFCC00;">(between 30 and
																	365, default: 30)</span>
															</td>
														</tr>
														<tr class="even" id="rowautomatedtests">
															<td class="settingname">Enable automatic ping tests</td>
															<td class="settingvalue">
																<input type="radio" name="connmon_automated"
																	id="connmon_auto_true"
																	onchange="automaticTestEnableDisable(this)"
																	class="input" value="true" checked>
																<label for="connmon_auto_true">Yes</label>
																<input type="radio" name="connmon_automated"
																	id="connmon_auto_false"
																	onchange="automaticTestEnableDisable(this)"
																	class="input" value="false">
																<label for="connmon_auto_false">No</label>
															</td>
														</tr>
														<tr class="even" id="rowschedule">
															<td class="settingname">Schedule for automatic ping tests
															</td>
															<td class="settingvalue">
																<div class="schedulesettings" id="schdays">
																	<span class="schedulespan"
																		style="vertical-align:top;">Day(s)</span>
																	<input type="checkbox" name="connmon_schdays"
																		id="connmon_mon" class="input" value="Mon"
																		style="margin-left:0;"><label
																		for="connmon_mon">Mon</label>
																	<input type="checkbox" name="connmon_schdays"
																		id="connmon_tues" class="input"
																		value="Tues"><label
																		for="connmon_tues">Tues</label>
																	<input type="checkbox" name="connmon_schdays"
																		id="connmon_wed" class="input"
																		value="Wed"><label for="connmon_wed">Wed</label>
																	<input type="checkbox" name="connmon_schdays"
																		id="connmon_thurs" class="input"
																		value="Thurs"><label
																		for="connmon_thurs">Thurs</label>
																	<input type="checkbox" name="connmon_schdays"
																		id="connmon_fri" class="input"
																		value="Fri"><label for="connmon_fri">Fri</label>
																	<input type="checkbox" name="connmon_schdays"
																		id="connmon_sat" class="input"
																		value="Sat"><label for="connmon_sat">Sat</label>
																	<input type="checkbox" name="connmon_schdays"
																		id="connmon_sun" class="input"
																		value="Sun"><label for="connmon_sun">Sun</label>
																</div>
																<div class="schedulesettings" id="schmode">
																	<span class="schedulespan"
																		style="vertical-align:top;">Mode</span>
																	<input type="radio"
																		onchange="scheduleModeToggle(this)"
																		name="schedulemode" id="schmode_everyx"
																		class="input" value="EveryX" checked><label
																		for="schmode_everyx">Every X
																		hours/minutes</label>
																	<input type="radio"
																		onchange="scheduleModeToggle(this)"
																		name="schedulemode" id="schmode_custom"
																		class="input" value="Custom"><label
																		for="schmode_custom">Custom</label>
																</div>
																<div style="margin-bottom:0;" class="schedulesettings"
																	id="schfrequency">
																	<span class="schedulespan">Frequency</span>
																	<span style="color:#fff;margin-left:3px;">Every
																	</span>
																	<input autocomplete="off" style="text-align:center;"
																		type="text" maxlength="2"
																		class="input_3_table removespacing"
																		name="everyxvalue" id="everyxvalue" value="3"
																		onkeypress="return validator.isNumber(this,event)"
																		onkeyup="validateScheduleValue(this)"
																		onblur="validateScheduleValue(this)" />
																	&nbsp;<select name="everyxselect" id="everyxselect"
																		class="input_option"
																		onchange="everyXToggle(this)">
																		<option value="hours">hours</option>
																		<option value="minutes" selected>minutes
																		</option>
																	</select>
																	<span id="spanxhours" style="color:#FFCC00;">
																		(between 1 and 24)</span>
																	<span id="spanxminutes" style="color:#FFCC00;">
																		(between 1 and 30, default: 3)</span>
																</div>
																<div id="schcustom">
																	<div class="schedulesettings">
																		<a class="hintstyle" href="javascript:void(0);"
																			onclick="settingHint(1);">
																			<span class="schedulespan">Hours</span>
																		</a>
																		<input data-lpignore="true" autocomplete="off"
																			autocapitalize="off" type="text"
																			class="input_25_table"
																			name="connmon_schhours" value="*"
																			onkeyup="validateSchedule(this,'hours')"
																			onblur="validateSchedule(this,'hours')" />
																		<input id="btnfixhours" type="button"
																			onclick="fixCron('hours');" value="Fix?"
																			class="button_gen cronbutton" name="button"
																			style="display:none;">
																	</div>
																	<div class="schedulesettings">
																		<a class="hintstyle" href="javascript:void(0);"
																			onclick="settingHint(2);">
																			<span class="schedulespan">Minutes</span>
																		</a>
																		<input data-lpignore="true" autocomplete="off"
																			autocapitalize="off" type="text"
																			class="input_25_table"
																			name="connmon_schmins" value="*"
																			onkeyup="validateSchedule(this,'mins')"
																			onblur="validateSchedule(this,'mins')" />
																		<input id="btnfixmins" type="button"
																			onclick="fixCron('mins');" value="Fix?"
																			class="button_gen cronbutton" name="button"
																			style="display:none;">
																	</div>
																</div>
															</td>
														</tr>
														<tr class="even" id="rowtimeoutput">
															<td class="settingname">Time Output Mode<br /><span
																	class="settingname">(for CSV export)</span></td>
															<td class="settingvalue">
																<input type="radio" name="connmon_outputtimemode"
																	id="connmon_timeoutput_non-unix" class="input"
																	value="non-unix" checked>
																<label
																	for="connmon_timeoutput_non-unix">Non-Unix</label>
																<input type="radio" name="connmon_outputtimemode"
																	id="connmon_timeoutput_unix" class="input"
																	value="unix">
																<label for="connmon_timeoutput_unix">Unix</label>
															</td>
														</tr>
														<tr class="even" id="rowstorageloc">
															<td class="settingname">Data Storage Location</td>
															<td class="settingvalue">
																<input type="radio" name="connmon_storagelocation"
																	id="connmon_storageloc_jffs" class="input"
																	value="jffs" checked>
																<label for="connmon_storageloc_jffs">JFFS</label>
																<input type="radio" name="connmon_storagelocation"
																	id="connmon_storageloc_usb" class="input"
																	value="usb">
																<label for="connmon_storageloc_usb">USB</label>
															</td>
														</tr>
														<tr class="even" id="rowexcludefromqos">
															<td class="settingname">Exclude ping tests from QoS</td>
															<td class="settingvalue">
																<input type="radio" name="connmon_excludefromqos"
																	id="connmon_exclude_true" class="input" value="true"
																	checked>
																<label for="connmon_exclude_true">Yes</label>
																<input type="radio" name="connmon_excludefromqos"
																	id="connmon_exclude_false" class="input"
																	value="false">
																<label for="connmon_exclude_false">No</label>
															</td>
														</tr>
													</table>
													<div style="line-height:10px;">&nbsp;</div>
													<table width="100%" border="0" align="center" cellpadding="4"
														cellspacing="0" bordercolor="#6b8fa3" class="FormTable"
														style="border:0;">
														<tr class="apply_gen" valign="top" height="35px">
															<td colspan="2" class="savebutton">
																<input type="button" onclick="saveConfig('Navigate3');"
																	value="Save" class="button_gen savebutton"
																	name="button" id="btnSaveNavigate3">
																<img id="imgSaveNavigate3"
																	style="display:none;vertical-align:middle;margin:5px;"
																	src="images/InternetScan.gif" />
															</td>
														</tr>
													</table>
												</div>
												<div id="Navigate4" style="display:none;">
													<table width="100%" border="1" align="center" cellpadding="2"
														cellspacing="0" bordercolor="#6b8fa3"
														class="FormTable SettingsTable" id="table_notificationstypes">
														<thead class="collapsible-jquery" id="notificationstypes">
															<tr>
																<td colspan="2">Notification Types</td>
															</tr>
														</thead>
														<tr>
															<td align="center" style="padding:0;">
																<button type="button"
																	class="button_gen notificationtypenavbutton"
																	onclick="jyNavigate(1,'NotificationType',4);"
																	id="btnNotificationTypeNavigate1">Ping test</button>
																<button type="button"
																	class="button_gen notificationtypenavbutton"
																	onclick="jyNavigate(2,'NotificationType',4);"
																	id="btnNotificationTypeNavigate2">Ping
																	threshold</button>
																<button type="button"
																	class="button_gen notificationtypenavbutton"
																	onclick="jyNavigate(3,'NotificationType',4);"
																	id="btnNotificationTypeNavigate3">Jitter
																	threshold</button>
																<button type="button"
																	class="button_gen notificationtypenavbutton"
																	onclick="jyNavigate(4,'NotificationType',4);"
																	id="btnNotificationTypeNavigate4">Line
																	Quality<br />threshold</button>
															</td>
														</tr>
													</table>
													<div id="NotificationTypeNavigate1">
														<div style="line-height:10px;">&nbsp;</div>
														<table width="100%" border="1" align="center" cellpadding="2"
															cellspacing="0" bordercolor="#6b8fa3"
															class="FormTable SettingsTable" id="table_pingtesttypes">
															<thead class="collapsible-jquery" id="pingtesttypes">
																<tr>
																	<td colspan="2">Ping Test Notifications</td>
																</tr>
															</thead>
															<tr class="even" id="rowpingtesttypes">
																<td class="settingname">Enabled notification methods
																</td>
																<td class="settingvalue">
																	<div id="pingtesttypefields"
																		style="padding-top:5px;padding-bottom:5px;">
																		<input type="checkbox"
																			name="connmon_notifications_pingtest"
																			id="connmon_pingtest_email" class="input"
																			value="Email"><label
																			for="connmon_pingtest_email"
																			class="notificationtype">Email</label>
																		<input type="checkbox"
																			name="connmon_notifications_pingtest"
																			id="connmon_pingtest_webhook" class="input"
																			value="Webhook"><label
																			for="connmon_pingtest_webhook"
																			class="notificationtype">Webhook</label>
																		<input type="checkbox"
																			name="connmon_notifications_pingtest"
																			id="connmon_pingtest_pushover" class="input"
																			value="Pushover"><label
																			for="connmon_pingtest_pushover"
																			class="notificationtype">Pushover</label>
																		<input type="checkbox"
																			name="connmon_notifications_pingtest"
																			id="connmon_pingtest_custom" class="input"
																			value="Custom"><label
																			for="connmon_pingtest_custom"
																			class="notificationtype">Custom</label>
																	</div>
																</td>
															</tr>
														</table>
														<div style="line-height:10px;">&nbsp;</div>
														<table width="100%" border="0" align="center" cellpadding="4"
															cellspacing="0" bordercolor="#6b8fa3" class="FormTable"
															style="border:0;">
															<tr class="apply_gen" valign="top" height="35px">
																<td colspan="2" class="savebutton">
																	<input type="button"
																		onclick="saveConfig('NotificationTypeNavigate1');"
																		value="Save" class="button_gen savebutton"
																		name="button"
																		id="btnSaveNotificationTypeNavigate1">
																	<img id="imgSaveNotificationTypeNavigate1"
																		style="display:none;vertical-align:middle;margin:5px;"
																		src="images/InternetScan.gif" />
																</td>
															</tr>
														</table>
													</div>
													<div id="NotificationTypeNavigate2">
														<div style="line-height:10px;">&nbsp;</div>
														<table width="100%" border="1" align="center" cellpadding="2"
															cellspacing="0" bordercolor="#6b8fa3"
															class="FormTable SettingsTable"
															id="table_pingthresholdtypes">
															<thead class="collapsible-jquery" id="pingthresholdtypes">
																<tr>
																	<td colspan="2">Ping Threshold Notifications</td>
																</tr>
															</thead>
															<tr class="even" id="rowpingthresholdvalue">
																<td class="settingname">Threshold value</td>
																<td class="settingvalue">
																	<input autocomplete="off" type="text" maxlength="8"
																		class="input_12_table removespacing"
																		name="connmon_notifications_pingthreshold_value"
																		value="30.000"
																		onkeypress="return validator.isNumberFloat(this, event)"
																		onkeyup="validateNumberSetting(this,9999,0)"
																		onblur="validateNumberSetting(this,9999,0);formatNumberSetting3DP(this)" />
																</td>
															</tr>
															<tr class="even" id="rowpingthresholdtypes">
																<td class="settingname">Enabled notification methods
																</td>
																<td class="settingvalue">
																	<div id="pingthresholdtypefields"
																		style="padding-top:5px;padding-bottom:5px;">
																		<input type="checkbox"
																			name="connmon_notifications_pingthreshold"
																			id="connmon_pingthreshold_email"
																			class="input" value="Email"><label
																			for="connmon_pingthreshold_email"
																			class="notificationtype">Email</label>
																		<input type="checkbox"
																			name="connmon_notifications_pingthreshold"
																			id="connmon_pingthreshold_webhook"
																			class="input" value="Webhook"><label
																			for="connmon_pingthreshold_webhook"
																			class="notificationtype">Webhook</label>
																		<input type="checkbox"
																			name="connmon_notifications_pingthreshold"
																			id="connmon_pingthreshold_pushover"
																			class="input" value="Pushover"><label
																			for="connmon_pingthreshold_pushover"
																			class="notificationtype">Pushover</label>
																		<input type="checkbox"
																			name="connmon_notifications_pingthreshold"
																			id="connmon_pingthreshold_custom"
																			class="input" value="Custom"><label
																			for="connmon_pingthreshold_custom"
																			class="notificationtype">Custom</label>
																	</div>
																</td>
															</tr>
														</table>
														<div style="line-height:10px;">&nbsp;</div>
														<table width="100%" border="0" align="center" cellpadding="4"
															cellspacing="0" bordercolor="#6b8fa3" class="FormTable"
															style="border:0;">
															<tr class="apply_gen" valign="top" height="35px">
																<td colspan="2" class="savebutton">
																	<input type="button"
																		onclick="saveConfig('NotificationTypeNavigate2');"
																		value="Save" class="button_gen savebutton"
																		name="button"
																		id="btnSaveNotificationTypeNavigate2">
																	<img id="imgSaveNotificationTypeNavigate2"
																		style="display:none;vertical-align:middle;margin:5px;"
																		src="images/InternetScan.gif" />
																</td>
															</tr>
														</table>
													</div>
													<div id="NotificationTypeNavigate3">
														<div style="line-height:10px;">&nbsp;</div>
														<table width="100%" border="1" align="center" cellpadding="2"
															cellspacing="0" bordercolor="#6b8fa3"
															class="FormTable SettingsTable"
															id="table_jitterthresholdtypes">
															<thead class="collapsible-jquery" id="jitterthresholdtypes">
																<tr>
																	<td colspan="2">Jitter Threshold Notifications</td>
																</tr>
															</thead>
															<tr class="even" id="rowjitterthresholdvalue">
																<td class="settingname">Threshold value</td>
																<td class="settingvalue">
																	<input autocomplete="off" type="text" maxlength="8"
																		class="input_12_table removespacing"
																		name="connmon_notifications_jitterthreshold_value"
																		value="15.000"
																		onkeypress="return validator.isNumberFloat(this, event)"
																		onkeyup="validateNumberSetting(this,9999,0)"
																		onblur="validateNumberSetting(this,9999,0);formatNumberSetting3DP(this)" />
																</td>
															</tr>
															<tr class="even" id="rowjitterthresholdtypes">
																<td class="settingname">Enabled notification methods
																</td>
																<td class="settingvalue">
																	<div id="jitterthresholdtypefields"
																		style="padding-top:5px;padding-bottom:5px;">
																		<input type="checkbox"
																			name="connmon_notifications_jitterthreshold"
																			id="connmon_jitterthreshold_email"
																			class="input" value="Email"><label
																			for="connmon_jitterthreshold_email"
																			class="notificationtype">Email</label>
																		<input type="checkbox"
																			name="connmon_notifications_jitterthreshold"
																			id="connmon_jitterthreshold_webhook"
																			class="input" value="Webhook"><label
																			for="connmon_jitterthreshold_webhook"
																			class="notificationtype">Webhook</label>
																		<input type="checkbox"
																			name="connmon_notifications_jitterthreshold"
																			id="connmon_jitterthreshold_pushover"
																			class="input" value="Pushover"><label
																			for="connmon_jitterthreshold_pushover"
																			class="notificationtype">Pushover</label>
																		<input type="checkbox"
																			name="connmon_notifications_jitterthreshold"
																			id="connmon_jitterthreshold_custom"
																			class="input" value="Custom"><label
																			for="connmon_jitterthreshold_custom"
																			class="notificationtype">Custom</label>
																	</div>
																</td>
															</tr>
														</table>
														<div style="line-height:10px;">&nbsp;</div>
														<table width="100%" border="0" align="center" cellpadding="4"
															cellspacing="0" bordercolor="#6b8fa3" class="FormTable"
															style="border:0;">
															<tr class="apply_gen" valign="top" height="35px">
																<td colspan="2" class="savebutton">
																	<input type="button"
																		onclick="saveConfig('NotificationTypeNavigate3');"
																		value="Save" class="button_gen savebutton"
																		name="button"
																		id="btnSaveNotificationTypeNavigate3">
																	<img id="imgSaveNotificationTypeNavigate3"
																		style="display:none;vertical-align:middle;margin:5px;"
																		src="images/InternetScan.gif" />
																</td>
															</tr>
														</table>
													</div>
													<div id="NotificationTypeNavigate4">
														<div style="line-height:10px;">&nbsp;</div>
														<table width="100%" border="1" align="center" cellpadding="2"
															cellspacing="0" bordercolor="#6b8fa3"
															class="FormTable SettingsTable"
															id="table_linequalitythresholdtypes">
															<thead class="collapsible-jquery"
																id="linequalitythresholdtypes">
																<tr>
																	<td colspan="2">Line Quality Notifications</td>
																</tr>
															</thead>
															<tr class="even" id="rowjlinequalitythresholdvalue">
																<td class="settingname">Threshold value</td>
																<td class="settingvalue">
																	<input autocomplete="off" type="text" maxlength="8"
																		class="input_12_table removespacing"
																		name="connmon_notifications_linequalitythreshold_value"
																		value="90.000"
																		onkeypress="return validator.isNumberFloat(this, event)"
																		onkeyup="validateNumberSetting(this,9999,0)"
																		onblur="validateNumberSetting(this,9999,0);formatNumberSetting3DP(this)" />
																</td>
															</tr>
															<tr class="even" id="rowlinequalitythresholdtypes">
																<td class="settingname">Enabled notification methods
																</td>
																<td class="settingvalue">
																	<div id="linequalitythresholdtypefields"
																		style="padding-top:5px;padding-bottom:5px;">
																		<input type="checkbox"
																			name="connmon_notifications_linequalitythreshold"
																			id="connmon_linequalitythreshold_email"
																			class="input" value="Email"><label
																			for="connmon_linequalitythreshold_email"
																			class="notificationtype">Email</label>
																		<input type="checkbox"
																			name="connmon_notifications_linequalitythreshold"
																			id="connmon_linequalitythreshold_webhook"
																			class="input" value="Webhook"><label
																			for="connmon_linequalitythreshold_webhook"
																			class="notificationtype">Webhook</label>
																		<input type="checkbox"
																			name="connmon_notifications_linequalitythreshold"
																			id="connmon_linequalitythreshold_pushover"
																			class="input" value="Pushover"><label
																			for="connmon_linequalitythreshold_pushover"
																			class="notificationtype">Pushover</label>
																		<input type="checkbox"
																			name="connmon_notifications_linequalitythreshold"
																			id="connmon_linequalitythreshold_custom"
																			class="input" value="Custom"><label
																			for="connmon_linequalitythreshold_custom"
																			class="notificationtype">Custom</label>
																	</div>
																</td>
															</tr>
														</table>
														<div style="line-height:10px;">&nbsp;</div>
														<table width="100%" border="0" align="center" cellpadding="4"
															cellspacing="0" bordercolor="#6b8fa3" class="FormTable"
															style="border:0;">
															<tr class="apply_gen" valign="top" height="35px">
																<td colspan="2" class="savebutton">
																	<input type="button"
																		onclick="saveConfig('NotificationTypeNavigate4');"
																		value="Save" class="button_gen savebutton"
																		name="button"
																		id="btnSaveNotificationTypeNavigate4">
																	<img id="imgSaveNotificationTypeNavigate4"
																		style="display:none;vertical-align:middle;margin:5px;"
																		src="images/InternetScan.gif" />
																</td>
															</tr>
														</table>
													</div>
													<div style="margin:10px 0 10px 5px;" class="splitLine"></div>
													<table width="100%" border="1" align="center" cellpadding="2"
														cellspacing="0" bordercolor="#6b8fa3"
														class="FormTable SettingsTable" id="table_notificationconfig">
														<thead class="collapsible-jquery" id="notificationsconfig">
															<tr>
																<td colspan="2">Notification Methods and Integrations
																</td>
															</tr>
														</thead>
														<tr>
															<td align="center" style="padding:0;">
																<button type="button"
																	class="button_gen notificationmethodnavbutton"
																	onclick="jyNavigate(1,'NotificationMethod',6);"
																	id="btnNotificationMethodNavigate1">Email</button>
																<button type="button"
																	class="button_gen notificationmethodnavbutton"
																	onclick="jyNavigate(2,'NotificationMethod',6);"
																	id="btnNotificationMethodNavigate2">Discord<br />webhook</button>
																<button type="button"
																	class="button_gen notificationmethodnavbutton"
																	onclick="jyNavigate(3,'NotificationMethod',6);"
																	id="btnNotificationMethodNavigate3">Pushover</button>
																<button type="button"
																	class="button_gen notificationmethodnavbutton"
																	onclick="jyNavigate(4,'NotificationMethod',6);"
																	id="btnNotificationMethodNavigate4">Custom<br />actions
																	and<br />scripts</button>
																<button type="button"
																	class="button_gen notificationmethodnavbutton"
																	onclick="jyNavigate(5,'NotificationMethod',6);"
																	id="btnNotificationMethodNavigate5">Healthchecks.io</button>
																<button type="button"
																	class="button_gen notificationmethodnavbutton"
																	onclick="jyNavigate(6,'NotificationMethod',6);"
																	id="btnNotificationMethodNavigate6">InfluxDB<br />exporting</button>
															</td>
														</tr>
													</table>
													<div id="NotificationMethodNavigate1">
														<div style="line-height:10px;">&nbsp;</div>
														<table width="100%" border="1" align="center" cellpadding="2"
															cellspacing="0" bordercolor="#6b8fa3"
															class="FormTable SettingsTable"
															id="table_connmonemailconfig">
															<thead class="collapsible-jquery" id="connmonemailconfig">
																<tr>
																	<td colspan="2">Email notifications</td>
																</tr>
															</thead>
															<tr class="even" id="rowemailconfig">
																<td class="settingname">Email</td>
																<td class="settingvalue">
																	<input type="radio"
																		name="connmon_notifications_email"
																		id="connmon_notifications_email_true"
																		class="input" value="true">
																	<label for="connmon_notifications_email_true"
																		style="vertical-align:middle;">Enabled</label>
																	<input type="radio"
																		name="connmon_notifications_email"
																		id="connmon_notifications_email_false"
																		class="input" value="false" checked>
																	<label for="connmon_notifications_email_false"
																		style="vertical-align:middle;">Disabled</label>
																	<input type="button" id="btnTestEmail"
																		onclick="testNotification('TestEmail');"
																		value="Test" class="button_gen testbutton">
																	<img id="imgTestEmail"
																		style="display:none;vertical-align:middle;margin:5px;"
																		src="images/InternetScan.gif" />
																</td>
															</tr>
															<tr class="even" id="rowemaillist">
																<td class="settingname">List of email addresses to send
																	notifications to<br /><span class="settingname"
																		style="color:#FFCC00;">(one per line)</span>
																</td>
																<td class="settingvalue" style="padding:2px;">
																	<textarea cols="75" rows="10" wrap="off"
																		id="connmon_notifications_email_list"
																		name="connmon_notifications_email_list"
																		class="textarea_log_table settings"
																		data-lpignore="true"></textarea>
																</td>
															</tr>
														</table>
														<div style="line-height:10px;">&nbsp;</div>
														<table width="100%" border="0" align="center" cellpadding="4"
															cellspacing="0" bordercolor="#6b8fa3" class="FormTable"
															style="border:0;">
															<tr class="apply_gen" valign="top" height="35px">
																<td colspan="2" class="savebutton">
																	<input type="button"
																		onclick="saveConfig('NotificationMethodNavigate1Config');"
																		value="Save" class="button_gen savebutton"
																		name="button"
																		id="btnSaveNotificationMethodNavigate1Config">
																	<img id="imgSaveNotificationMethodNavigate1Config"
																		style="display:none;vertical-align:middle;margin:5px;"
																		src="images/InternetScan.gif" />
																</td>
															</tr>
														</table>
														<div style="line-height:10px;">&nbsp;</div>
														<table width="100%" border="1" align="center" cellpadding="2"
															cellspacing="0" bordercolor="#6b8fa3"
															class="FormTable SettingsTable" id="table_emailconfig">
															<thead class="collapsible-jquery" id="emailconfig">
																<tr>
																	<td colspan="2">Email Configuration</td>
																</tr>
															</thead>
															<tr class="even" id="rowemailhelptext">
																<td colspan="2" class="settingname">
																	<input autocorrect="off" autocapitalize="off"
																		type="text" maxlength="255"
																		style="font-weight:bold;text-align:center;padding:0;background-color:#2f3a3e;border:0;width:100%"
																		class="input_32_table removespacing"
																		value="Note: the below configuration is shared with other addons/scripts, such as Diversion"
																		data-lpignore="true">
																</td>
															</tr>
															<tr class="even" id="rowemailinfo">
																<td colspan="2" class="settingvalue">
																	<textarea cols="75" rows="10" wrap="off"
																		readonly="readonly" id="emailinfo"
																		class="textarea_log_table"
																		style="font-size:11px;border:0;resize:none;"
																		data-lpignore="true"></textarea>
																</td>
															</tr>
															<tr class="even" id="rowemailfromaddress">
																<td class="settingname">From Address</td>
																<td class="settingvalue">
																	<input autocorrect="off" autocapitalize="off"
																		type="text" maxlength="255"
																		style="text-align:left;padding-left:5px;"
																		class="input_32_table removespacing"
																		name="email_from_address" value=""
																		onkeypress="return validator.isString(this,event);"
																		data-lpignore="true" />
																</td>
															</tr>
															<tr class="even" id="rowemailtoaddress">
																<td class="settingname">To Address</td>
																<td class="settingvalue">
																	<input autocorrect="off" autocapitalize="off"
																		type="text" maxlength="255"
																		style="text-align:left;padding-left:5px;"
																		class="input_32_table removespacing"
																		name="email_to_address" value=""
																		onkeypress="return validator.isString(this,event);"
																		data-lpignore="true" />
																</td>
															</tr>
															<tr class="even" id="rowemailtoname">
																<td class="settingname">To name</td>
																<td class="settingvalue">
																	<input autocorrect="off" autocapitalize="off"
																		type="text" maxlength="255"
																		style="text-align:left;padding-left:5px;"
																		class="input_32_table removespacing"
																		name="email_to_name" value=""
																		onkeypress="return validator.isString(this,event);"
																		data-lpignore="true" />
																</td>
															</tr>
															<tr class="even" id="rowemailusername">
																<td class="settingname">Username</td>
																<td class="settingvalue">
																	<input autocorrect="off" autocapitalize="off"
																		type="text" maxlength="255"
																		style="text-align:left;padding-left:5px;"
																		class="input_32_table removespacing"
																		name="email_username" value=""
																		onkeypress="return validator.isString(this,event);"
																		data-lpignore="true" />
																</td>
															</tr>
															<tr class="even" id="rowmemailpassword">
																<td class="settingname">Password</td>
																<td class="settingvalue">
																	<input autocomplete="off" autocapitalize="off"
																		type="password" class="input_30_table"
																		onchange="" name="email_password"
																		id="email_password">&nbsp;&nbsp;&nbsp;<input
																		type="checkbox" name="show_pass_email_password"
																		onclick="passChecked(document.form.email_password,document.form.show_pass_email_password)"
																		style="vertical-align:middle;"><label
																		for="email_password"
																		style="vertical-align:middle;margin-right:10px;margin-bottom:5px;">Show
																		password?</label>
																</td>
															</tr>
															<tr class="even" id="rowemailfriendlyroutername">
																<td class="settingname">Friendly Router Name</td>
																<td class="settingvalue">
																	<input autocorrect="off" autocapitalize="off"
																		type="text" maxlength="255"
																		style="text-align:left;padding-left:5px;"
																		class="input_32_table removespacing"
																		name="email_friendly_router_name" value=""
																		onkeypress="return validator.isString(this,event);"
																		data-lpignore="true" />
																</td>
															</tr>
															<tr class="even" id="rowemailsmtpaddress">
																<td class="settingname">SMTP address</td>
																<td class="settingvalue">
																	<input autocorrect="off" autocapitalize="off"
																		type="text" maxlength="255"
																		style="text-align:left;padding-left:5px;"
																		class="input_32_table removespacing"
																		name="email_smtp" value=""
																		onkeypress="return validator.isString(this,event);"
																		onblur="validateDomain(this)"
																		onkeyup="validateDomain(this)"
																		data-lpignore="true" />
																</td>
															</tr>
															<tr class="even" id="rowemailport">
																<td class="settingname">SMTP Port</td>
																<td class="settingvalue">
																	<input autocomplete="off" type="text" maxlength="5"
																		class="input_6_table removespacing"
																		name="email_port" value="465"
																		onkeypress="return validator.isNumber(this,event)"
																		data-lpignore="true" />
																</td>
															</tr>
															<tr class="even" id="rowemailprotocol">
																<td class="settingname">SMTP protocol</td>
																<td class="settingvalue">
																	<input type="radio" name="email_protocol"
																		id="email_protocol_smtps" class="input"
																		value="smtps" checked>
																	<label for="email_protocol_smtps">smtps</label>
																	<input type="radio" name="email_protocol"
																		id="email_protocol_smtp" class="input"
																		value="smtp">
																	<label for="email_protocol_smtp">smtp</label>
																</td>
															</tr>
															<tr class="even" id="rowemailsslflag">
																<td class="settingname">SSL Requirement</td>
																<td class="settingvalue">
																	<input type="radio" name="email_ssl_flag"
																		id="email_ssl_flag_secure" class="input"
																		value="" checked>
																	<label for="email_ssl_flag_secure">Secure</label>
																	<input type="radio" name="email_ssl_flag"
																		id="email_ssl_flag_insecure" class="input"
																		value="--insecure">
																	<label
																		for="email_ssl_flag_insecure">Insecure</label>
																</td>
															</tr>
														</table>
														<div style="line-height:10px;">&nbsp;</div>
														<table width="100%" border="0" align="center" cellpadding="4"
															cellspacing="0" bordercolor="#6b8fa3" class="FormTable"
															style="border:0;">
															<tr class="apply_gen" valign="top" height="35px">
																<td colspan="2" class="savebutton">
																	<input type="button"
																		onclick="saveConfig('NotificationMethodNavigate1Email');"
																		value="Save" class="button_gen savebutton"
																		name="button"
																		id="btnSaveNotificationMethodNavigate1Email">
																	<img id="imgSaveNotificationMethodNavigate1Email"
																		style="display:none;vertical-align:middle;margin:5px;"
																		src="images/InternetScan.gif" />
																</td>
															</tr>
														</table>
													</div>
													<div id="NotificationMethodNavigate2">
														<div style="line-height:10px;">&nbsp;</div>
														<table width="100%" border="1" align="center" cellpadding="2"
															cellspacing="0" bordercolor="#6b8fa3"
															class="FormTable SettingsTable" id="table_webhookconfig">
															<thead class="collapsible-jquery" id="webhookconfig">
																<tr>
																	<td colspan="2">Discord Webhooks</td>
																</tr>
															</thead>
															<tr class="even" id="rowwebhookconfig">
																<td class="settingname">Discord Webhooks</td>
																<td class="settingvalue">
																	<input type="radio"
																		name="connmon_notifications_webhook"
																		id="connmon_notifications_webhook_true"
																		class="input" value="true">
																	<label for="connmon_notifications_webhook_true"
																		style="vertical-align:middle;">Enabled</label>
																	<input type="radio"
																		name="connmon_notifications_webhook"
																		id="connmon_notifications_webhook_false"
																		class="input" value="false" checked>
																	<label for="connmon_notifications_webhook_false"
																		style="vertical-align:middle;">Disabled</label>
																	<input type="button" id="btnTestWebhooks"
																		onclick="testNotification('TestWebhooks');"
																		value="Test" class="button_gen testbutton">
																	<img id="imgTestWebhooks"
																		style="display:none;vertical-align:middle;margin:5px;"
																		src="images/InternetScan.gif" />
																</td>
															</tr>
															<tr class="even" id="rowwebhooks">
																<td class="settingname">List of Discord
																	webhooks<br /><span class="settingname"
																		style="color:#FFCC00;">(one per line)</span>
																</td>
																<td class="settingvalue" style="padding:2px;">
																	<textarea cols="75" rows="10" wrap="off"
																		id="connmon_notifications_webhook_list"
																		name="connmon_notifications_webhook_list"
																		class="textarea_log_table settings"
																		data-lpignore="true"></textarea>
																</td>
															</tr>
														</table>
														<div style="line-height:10px;">&nbsp;</div>
														<table width="100%" border="0" align="center" cellpadding="4"
															cellspacing="0" bordercolor="#6b8fa3" class="FormTable"
															style="border:0;">
															<tr class="apply_gen" valign="top" height="35px">
																<td colspan="2" class="savebutton">
																	<input type="button"
																		onclick="saveConfig('NotificationMethodNavigate2');"
																		value="Save" class="button_gen savebutton"
																		name="button"
																		id="btnSaveNotificationMethodNavigate2">
																	<img id="imgSaveNotificationMethodNavigate2"
																		style="display:none;vertical-align:middle;margin:5px;"
																		src="images/InternetScan.gif" />
																</td>
															</tr>
														</table>
													</div>
													<div id="NotificationMethodNavigate3">
														<div style="line-height:10px;">&nbsp;</div>
														<table width="100%" border="1" align="center" cellpadding="2"
															cellspacing="0" bordercolor="#6b8fa3"
															class="FormTable SettingsTable" id="table_pushoverconfig">
															<thead class="collapsible-jquery" id="pushoverconfig">
																<tr>
																	<td colspan="2">Pushover</td>
																</tr>
															</thead>
															<tr class="even" id="rowpushoverconfig">
																<td class="settingname">Pushover</td>
																<td class="settingvalue">
																	<input type="radio"
																		name="connmon_notifications_pushover"
																		id="connmon_notifications_pushover_true"
																		class="input" value="true">
																	<label for="connmon_notifications_pushover_true"
																		style="vertical-align:middle;">Enabled</label>
																	<input type="radio"
																		name="connmon_notifications_pushover"
																		id="connmon_notifications_pushover_false"
																		class="input" value="false" checked>
																	<label for="connmon_notifications_pushover_false"
																		style="vertical-align:middle;">Disabled</label>
																	<input type="button" id="btnTestPushover"
																		onclick="testNotification('TestPushover');"
																		value="Test" class="button_gen testbutton">
																	<img id="imgTestPushover"
																		style="display:none;vertical-align:middle;margin:5px;"
																		src="images/InternetScan.gif" />
																</td>
															</tr>
															<tr class="even" id="rowpushoverapi">
																<td class="settingname">Pushover API Token</td>
																<td class="settingvalue">
																	<input autocorrect="off" autocapitalize="off"
																		type="text" maxlength="255"
																		style="text-align:left;padding-left:5px;"
																		class="input_32_table removespacing"
																		name="connmon_notifications_pushover_api"
																		value=""
																		onkeypress="return validator.isString(this,event);"
																		data-lpignore="true" />
																</td>
															</tr>
															<tr class="even" id="rowpushoveruserkey">
																<td class="settingname">Pushover User Key</td>
																<td class="settingvalue">
																	<input autocorrect="off" autocapitalize="off"
																		type="text" maxlength="255"
																		style="text-align:left;padding-left:5px;"
																		class="input_32_table removespacing"
																		name="connmon_notifications_pushover_userkey"
																		value=""
																		onkeypress="return validator.isString(this,event);"
																		data-lpignore="true" />
																</td>
															</tr>
															<tr class="even" id="rowpushoverdevices">
																<td class="settingname">List of devices to send
																	Pushovers to<br /><span class="settingname"
																		style="color:#FFCC00;">(leave blank to notify
																		all devices)</span><br /><span
																		class="settingname" style="color:#FFCC00;">(one
																		per line)</span></td>
																<td class="settingvalue" style="padding:2px;">
																	<textarea cols="75" rows="10" wrap="off"
																		id="connmon_notifications_pushover_list"
																		name="connmon_notifications_pushover_list"
																		class="textarea_log_table settings"
																		data-lpignore="true"></textarea>
																</td>
															</tr>
														</table>
														<div style="line-height:10px;">&nbsp;</div>
														<table width="100%" border="0" align="center" cellpadding="4"
															cellspacing="0" bordercolor="#6b8fa3" class="FormTable"
															style="border:0;">
															<tr class="apply_gen" valign="top" height="35px">
																<td colspan="2" class="savebutton">
																	<input type="button"
																		onclick="saveConfig('NotificationMethodNavigate3');"
																		value="Save" class="button_gen savebutton"
																		name="button"
																		id="btnSaveNotificationMethodNavigate3">
																	<img id="imgSaveNotificationMethodNavigate3"
																		style="display:none;vertical-align:middle;margin:5px;"
																		src="images/InternetScan.gif" />
																</td>
															</tr>
														</table>
													</div>
													<div id="NotificationMethodNavigate4">
														<div style="line-height:10px;">&nbsp;</div>
														<table width="100%" border="1" align="center" cellpadding="2"
															cellspacing="0" bordercolor="#6b8fa3"
															class="FormTable SettingsTable"
															id="table_customactionsconfig">
															<thead class="collapsible-jquery" id="customactionsconfig">
																<tr>
																	<td colspan="2">Custom actions and scripts</td>
																</tr>
															</thead>
															<tr class="even" id="rowcustomactions">
																<td class="settingname">Custom actions and scripts</td>
																<td class="settingvalue">
																	<input type="radio"
																		name="connmon_notifications_custom"
																		id="connmon_notifications_custom_true"
																		class="input" value="true">
																	<label for="connmon_notifications_custom_true"
																		style="vertical-align:middle;">Enabled</label>
																	<input type="radio"
																		name="connmon_notifications_custom"
																		id="connmon_notifications_custom_false"
																		class="input" value="false" checked>
																	<label for="connmon_notifications_custom_false"
																		style="vertical-align:middle;">Disabled</label>
																	<input type="button" id="btnTestCustomActions"
																		onclick="testNotification('TestCustomActions');"
																		value="Test" class="button_gen testbutton">
																	<img id="imgTestCustomActions"
																		style="display:none;vertical-align:middle;margin:5px;"
																		src="images/InternetScan.gif" />
																</td>
															</tr>
															<tr class="even" id="rowcustomactioninfo">
																<td colspan="2" class="settingvalue">
																	<textarea cols="75" rows="20" wrap="off"
																		readonly="readonly" id="customaction_details"
																		class="textarea_log_table"
																		style="font-size:11px;border:0;resize:none;"
																		data-lpignore="true"></textarea>
																</td>
															</tr>
														</table>
														<div style="line-height:10px;">&nbsp;</div>
														<table width="100%" border="0" align="center" cellpadding="4"
															cellspacing="0" bordercolor="#6b8fa3" class="FormTable"
															style="border:0;">
															<tr class="apply_gen" valign="top" height="35px">
																<td colspan="2" class="savebutton">
																	<input type="button"
																		onclick="saveConfig('NotificationMethodNavigate4');"
																		value="Save" class="button_gen savebutton"
																		name="button"
																		id="btnSaveNotificationMethodNavigate4">
																	<img id="imgSaveNotificationMethodNavigate4"
																		style="display:none;vertical-align:middle;margin:5px;"
																		src="images/InternetScan.gif" />
																</td>
															</tr>
														</table>
													</div>
													<div id="NotificationMethodNavigate5">
														<div style="line-height:10px;">&nbsp;</div>
														<table width="100%" border="1" align="center" cellpadding="2"
															cellspacing="0" bordercolor="#6b8fa3"
															class="FormTable SettingsTable"
															id="table_healthchecksioconfig">
															<thead class="collapsible-jquery" id="healthchecksioconfig">
																<tr>
																	<td colspan="2">Healthchecks.io monitoring</td>
																</tr>
															</thead>
															<tr class="even" id="rowhealthchecksio">
																<td class="settingname">Healthchecks.io monitoring</td>
																<td class="settingvalue">
																	<input type="radio"
																		name="connmon_notifications_healthcheck"
																		id="connmon_notifications_healthcheck_true"
																		class="input" value="true">
																	<label for="connmon_notifications_healthcheck_true"
																		style="vertical-align:middle;">Enabled</label>
																	<input type="radio"
																		name="connmon_notifications_healthcheck"
																		id="connmon_notifications_healthcheck_false"
																		class="input" value="false" checked>
																	<label for="connmon_notifications_healthcheck_false"
																		style="vertical-align:middle;">Disabled</label>
																	<input type="button" id="btnTestHealthcheck"
																		onclick="testNotification('TestHealthcheck');"
																		value="Test" class="button_gen testbutton">
																	<img id="imgTestHealthcheck"
																		style="display:none;vertical-align:middle;margin:5px;"
																		src="images/InternetScan.gif" />
																</td>
															</tr>
															<tr class="even" id="rowhealthcheckuuid">
																<td class="settingname">Healthcheck UUID</td>
																<td class="settingvalue">
																	<input autocorrect="off" autocapitalize="off"
																		type="text" maxlength="255"
																		style="text-align:left;padding-left:5px;"
																		class="input_32_table removespacing"
																		name="connmon_notifications_healthcheck_uuid"
																		value=""
																		onkeypress="return validator.isString(this,event);"
																		data-lpignore="true" />
																</td>
															</tr>
															<tr class="even" id="rowhealthcheckcron">
																<td class="settingname">Healthcheck Cron Schedule</td>
																<td class="settingvalue">
																	<input autocorrect="off" autocapitalize="off"
																		type="text" readonly="readonly" maxlength="255"
																		style="text-align:left;padding-left:5px;background-color:#475A5F;border:0;"
																		class="input_32_table removespacing"
																		id="healthcheckio_cron"
																		name="healthcheckio_cron" value=""
																		data-lpignore="true" />
																</td>
															</tr>
														</table>
														<div style="line-height:10px;">&nbsp;</div>
														<table width="100%" border="0" align="center" cellpadding="4"
															cellspacing="0" bordercolor="#6b8fa3" class="FormTable"
															style="border:0;">
															<tr class="apply_gen" valign="top" height="35px">
																<td colspan="2" class="savebutton">
																	<input type="button"
																		onclick="saveConfig('NotificationMethodNavigate5');"
																		value="Save" class="button_gen savebutton"
																		name="button"
																		id="btnSaveNotificationMethodNavigate5">
																	<img id="imgSaveNotificationMethodNavigate5"
																		style="display:none;vertical-align:middle;margin:5px;"
																		src="images/InternetScan.gif" />
																</td>
															</tr>
														</table>
													</div>
													<div id="NotificationMethodNavigate6">
														<div style="line-height:10px;">&nbsp;</div>
														<table width="100%" border="1" align="center" cellpadding="2"
															cellspacing="0" bordercolor="#6b8fa3"
															class="FormTable SettingsTable" id="table_influxdbconfig">
															<thead class="collapsible-jquery" id="influxdbconfig">
																<tr>
																	<td colspan="2">InfluxDB exporting</td>
																</tr>
															</thead>
															<tr class="even" id="rowinfluxdb">
																<td class="settingname">InfluxDB exporting</td>
																<td class="settingvalue">
																	<input type="radio"
																		name="connmon_notifications_influxdb"
																		id="connmon_notifications_influxdb_true"
																		class="input" value="true">
																	<label for="connmon_notifications_influxdb_true"
																		style="vertical-align:middle;">Enabled</label>
																	<input type="radio"
																		name="connmon_notifications_influxdb"
																		id="connmon_notifications_influxdb_false"
																		class="input" value="false" checked>
																	<label for="connmon_notifications_influxdb_false"
																		style="vertical-align:middle;">Disabled</label>
																	<input type="button" id="btnTestInfluxDB"
																		onclick="testNotification('TestInfluxDB');"
																		value="Test" class="button_gen testbutton">
																	<img id="imgTestInfluxDB"
																		style="display:none;vertical-align:middle;margin:5px;"
																		src="images/InternetScan.gif" />
																</td>
															</tr>
															<tr class="even" id="rowinfluxdbhost">
																<td class="settingname">InfluxDB Host</td>
																<td class="settingvalue">
																	<input autocorrect="off" autocapitalize="off"
																		type="text" maxlength="255"
																		style="text-align:left;padding-left:5px;"
																		class="input_32_table removespacing"
																		name="connmon_notifications_influxdb_host"
																		value=""
																		onkeypress="return validator.isString(this,event);"
																		onblur="validateDomainOrIP(this)"
																		onkeyup="validateDomainOrIP(this)"
																		data-lpignore="true" />
																</td>
															</tr>
															<tr class="even" id="rowinfluxdbport">
																<td class="settingname">InfluxDB Port</td>
																<td class="settingvalue">
																	<input autocomplete="off" type="text" maxlength="5"
																		class="input_6_table removespacing"
																		name="connmon_notifications_influxdb_port"
																		value="8086"
																		onkeypress="return validator.isNumber(this,event)"
																		data-lpignore="true" />
																</td>
															</tr>
															<tr class="even" id="rowinfluxdbdb">
																<td class="settingname">InfluxDB Database</td>
																<td class="settingvalue">
																	<input autocorrect="off" autocapitalize="off"
																		type="text" maxlength="255"
																		style="text-align:left;padding-left:5px;"
																		class="input_32_table removespacing"
																		name="connmon_notifications_influxdb_db"
																		value="connmon"
																		onkeypress="return validator.isString(this,event);"
																		data-lpignore="true" />
																</td>
															</tr>
															<tr class="even" id="rowinfluxdbversion">
																<td class="settingname">InfluxDB version</td>
																<td class="settingvalue">
																	<input type="radio"
																		name="connmon_notifications_influxdb_version"
																		id="connmon_notifications_influxdb_version_20"
																		class="input" value="2.0" checked>
																	<label
																		for="connmon_notifications_influxdb_20">2.0</label>
																	<input type="radio"
																		name="connmon_notifications_influxdb_version"
																		id="connmon_notifications_influxdb_version_18"
																		class="input" value="1.8">
																	<label
																		for="connmon_notifications_influxdb_18">1.8</label>
																</td>
															</tr>
															<tr class="even" id="rowinfluxdbusername">
																<td class="settingname">InfluxDB Username<br /><span
																		class="settingname">(v1.8+ only)</span></td>
																<td class="settingvalue">
																	<input autocorrect="off" autocapitalize="off"
																		type="text" maxlength="255"
																		style="text-align:left;padding-left:5px;"
																		class="input_32_table removespacing"
																		name="connmon_notifications_influxdb_username"
																		value=""
																		onkeypress="return validator.isString(this,event);"
																		data-lpignore="true" />
																</td>
															</tr>
															<tr class="even" id="rowinfluxdbpassword">
																<td class="settingname">InfluxDB Password<br /><span
																		class="settingname">(v1.8+ only)</span></td>
																<td class="settingvalue">
																	<input autocomplete="off" autocapitalize="off"
																		type="password" class="input_30_table"
																		onchange=""
																		name="connmon_notifications_influxdb_password"
																		id="connmon_notifications_influxdb_password">&nbsp;&nbsp;&nbsp;<input
																		type="checkbox"
																		name="show_pass_influxdb_password"
																		onclick="passChecked(document.form.connmon_notifications_influxdb_password,document.form.show_pass_influxdb_password)"
																		style="vertical-align:middle;"><label
																		for="connmon_notifications_influxdb_password"
																		style="vertical-align:middle;margin-right:10px;margin-bottom:5px;">Show
																		password?</label>
																</td>
															</tr>
															<tr class="even" id="rowinfluxdbapitoken">
																<td class="settingname">InfluxDB API Token<br /><span
																		class="settingname">(v2.x only)</span></td>
																<td class="settingvalue">
																	<input autocorrect="off" autocapitalize="off"
																		type="text" maxlength="255"
																		style="text-align:left;padding-left:5px;"
																		class="input_32_table removespacing"
																		name="connmon_notifications_influxdb_apitoken"
																		value=""
																		onkeypress="return validator.isString(this,event);"
																		data-lpignore="true" />
																</td>
															</tr>
														</table>
														<div style="line-height:10px;">&nbsp;</div>
														<table width="100%" border="0" align="center" cellpadding="4"
															cellspacing="0" bordercolor="#6b8fa3" class="FormTable"
															style="border:0;">
															<tr class="apply_gen" valign="top" height="35px">
																<td colspan="2" class="savebutton">
																	<input type="button"
																		onclick="saveConfig('NotificationMethodNavigate6');"
																		value="Save" class="button_gen savebutton"
																		name="button"
																		id="btnSaveNotificationMethodNavigate6">
																	<img id="imgSaveNotificationMethodNavigate6"
																		style="display:none;vertical-align:middle;margin:5px;"
																		src="images/InternetScan.gif" />
																</td>
															</tr>
														</table>
													</div>
												</div>
												<div id="Navigate5" style="display:none;">
													<table width="100%" border="1" align="center" cellpadding="2"
														cellspacing="0" bordercolor="#6b8fa3"
														class="FormTable SettingsTable" id="table_changelog">
														<thead class="collapsible-jquery" id="header_changelog">
															<tr>
																<td colspan="2">Changelog</td>
															</tr>
														</thead>
														<tr class="even" id="rowchangelog">
															<td colspan="2" class="settingvalue" style="padding:2px;">
																<textarea cols="75" rows="55" wrap="soft"
																	readonly="readonly" id="divchangelog"
																	class="textarea_log_table" style="border:0;"
																	data-lpignore="true"></textarea>
															</td>
														</tr>
													</table>
												</div>
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
	<div id="footer"></div>
</body>
</html>
