<!DOCTYPE html>
<html>
<head>
	<title>nGrinder Performance Test Detail</title>
	<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
	<META HTTP-EQUIV="Expires" CONTENT="-1">
	<#include "../common/common.ftl"> 
	<#include "../common/jqplot.ftl">
	<link href="${req.getContextPath()}/js/select2/select2.css" rel="stylesheet"/>
	<script src="${req.getContextPath()}/js/select2/select2.js"></script>
	<link href="${req.getContextPath()}/css/slider.css" rel="stylesheet">
	<link href="${req.getContextPath()}/plugins/datepicker/css/datepicker.css" rel="stylesheet">
	<style>
	div.div-resources {
		border: 1px solid #D6D6D6;
		height: 50px;
		margin-bottom: 8px;
		overflow-y: scroll;
		border-radius: 3px 3px 3px 3px;
	}
	
	div.div-resources .resource {
		color: #666666;
		display: inline-block;
		margin-left: 7px;
		margin-top: 2px;
		margin-bottom: 2px;
	}
	
	.select-item {
		width: 50px;
	}
	
	.control-label input {
		vertical-align: top;
		margin-left: 2px
	}
	
	.controls code {
		vertical-align: middle;
	}
	
	div.chart {
		border: 1px solid #878988;
		margin-bottom: 12px;
	}
	
	
	.table thead th {
		vertical-align: middle;
	}
	
	.jqplot-yaxis {
	    margin-right: 20px; 
	}
	
	.jqplot-xaxis {
	    margin-top: 5px; 
	} 
	
	.rampChart {
		width: 430px;
		height: 355px
	}
	
	div.div-host {
		border: 1px solid #D6D6D6;
		height: 50px;
		margin-bottom: 8px;
		overflow-y: scroll;
		border-radius: 3px 3px 3px 3px;
	}
	
	div.div-host .host {
		color: #666666;
		display: inline-block;
		margin-left: 7px;
		margin-top: 2px;
		margin-bottom: 2px;
	}
	
	.addhostbtn {
		margin-right:20px;
		margin-top:-32px;
	}
	
	i.expand {
		background-image: url('${req.getContextPath()}/img/icon_expand.png');
		background-repeat:no-repeat;
		display: inline-block;
	    height: 16px;
	    width: 16px; 
	    line-height: 16px;
	    vertical-align: text-top;
	}
	
	i.collapse{
		background-image: url('${req.getContextPath()}/img/icon_collapse.png');
		background-repeat:no-repeat;
		display: inline-block;
	    height: 16px;
	    width: 16px;
	    line-height: 16px;
	    vertical-align: text-top;
	}
	</style>

</head>

<body>
	<#include "../common/navigator.ftl">
	<div class="container">
		<form id="testContentForm" name="testContentForm" action="${req.getContextPath()}/perftest/create" method="POST"
			style="margin-bottom: 0;">
			<div class="well">
				<input type="hidden" id="testId" name="id" value="${(test.id)!}"> 
				<input type="hidden" id="threshold"	name="threshold" value="${(test.threshold)!"D"}"> 

				<div class="form-horizontal">
					<fieldset>
						<div class="control-group">
							<label for="testName" class="header-control-label control-label"><@spring.message "perfTest.table.testName"/></label>
							<div class="header-controls">
								<input class="required pull-left" maxlength="80" size="40" type="text" id="testName" name="testName" value="${(test.testName)!}">
								<input class="required span3" maxlength="80" size="60" type="text" id="tagString" name="tagString" value="${(test.tagString)!}">
								
								<#if test??> 
									<span id="teststatus_pop_over"
										rel="popover" data-content='${"${test.progressMessage}<br/><b>${test.lastProgressMessage}</b>"?replace('\n', '<br>')?html}'  
											data-original-title="<@spring.message "${test.status.springMessageKey}"/>" type="toggle" placement="bottom">
										<img id="testStatus_img_id" src="${req.getContextPath()}/img/ball/${test.status.iconName}" />
									</span>

									<#if test.status != "SAVED" || test.createdUser.userId != currentUser.userId>
										<input type="hidden" id="isClone" name="isClone" value="true">
										<#assign isClone = true/>
									<#else>
										<input type="hidden" id="isClone" name="isClone" value="false">
										<#assign isClone = false/> 
									</#if>
								<#else>
									<input type="hidden" id="isClone" name="isClone" value="false">
									<#assign isClone = false/> 
								</#if>
								<button type="submit" class="btn btn-success" id="saveTestBtn" style="">
									<#if isClone>
										<@spring.message "perfTest.detail.clone"/>
									<#else>
										<@spring.message "common.button.save"/>
									</#if>
								</button>
								<button type="submit" class="btn btn-primary" style="margin-left:10px; width:120px"
									data-toggle="modal" href="#scheduleModal" id="saveScheduleBtn">
									<#if isClone>
										<@spring.message "perfTest.detail.clone"/>
									<#else>
										<@spring.message "common.button.save"/>
									</#if>
									&nbsp;<@spring.message "perfTest.detail.andStart"/>
								</button>
							</div>
						</div>
						<div class="control-group" style="margin-bottom: 0">
							<label for="description" class="header-control-label control-label"><@spring.message "common.label.description"/></label>
							<div class="header-controls controls">
								<textarea class="input-xlarge span9" id="description" rows="3" name="description" style="resize: none">${(test.description)!}</textarea>
							</div>
						</div>
					</fieldset>
				</div>
			</div>
			<!-- end well -->
			
			<div class="tabbable" style="margin-top: 20px">
				<ul class="nav nav-tabs" id="homeTab" style="margin-bottom: 5px">
					<li id="testContent_tab">
						<a href="#testContent" data-toggle="tab">
							<@spring.message "perfTest.configuration.testConfiguration"/>
						</a>
					</li> 
					<li id="runningContent_tab" style="display: none; ">
						<a href="#runningContent" data-toggle="tab" id="runningContentLink">
							<@spring.message "perfTest.testRunning.title"/>
						</a>
					</li>
				
					<li id="reportContent_tab" style="display: none; ">
						<a href="#reportContent" data-toggle="tab" id="reportLnk">
							<@spring.message "perfTest.report.title"/>
						</a>
					</li>
				</ul>
				<div class="tab-content">
					<div class="tab-pane" id="testContent">
						<div class="row">
							<div class="span6">
								<div class="page-header">
									<h4><@spring.message "perfTest.configuration.basicConfiguration"/></h4>
								</div>
								<div class="form-horizontal form-horizontal-2">
									<fieldset>
										<div class="control-group">
											<label for="agentCount" class="control-label"><@spring.message "perfTest.configuration.agent"/></label>
											<div class="controls">
												<div class="input-append">
													<input type="text" class="input required positiveNumber span1" number_limit="${(maxAgentSizePerConsole)}"
														id="agentCount" name="agentCount" value="${(test.agentCount)!}"
														data-content='<@spring.message "perfTest.configuration.agent.help"/>'
														data-original-title="<@spring.message "perfTest.configuration.agent"/>"><span class="add-on"><@spring.message "perfTest.configuration.max"/>${(maxAgentSizePerConsole)}</span>
										 		</div> 
											</div>
										</div>
										<div class="control-group">
											<label for="vuserPerAgent" class="control-label"><@spring.message "perfTest.configuration.vuserPerAgent"/></label>
											<div class="controls">
												<table style="width:100%">
													<colgroup>
														<col width="300px"/>
														<col width="*"/>
													</colgroup>
													<tr>
														<td>
															<div class="input-append">
																<input type="text" class="input required positiveNumber span1" rel="popover"
																	number_limit="${(maxVuserPerAgent)}" id="vuserPerAgent" name="vuserPerAgent"
																	value="${(test.vuserPerAgent)!}" 
																	rel="popover"	
																	data-content='<@spring.message "perfTest.configuration.vuserPerAgent.help"/>'
																	data-original-title="<@spring.message "perfTest.configuration.vuserPerAgent"/>"><span class="add-on"><@spring.message "perfTest.configuration.max"/>${(maxVuserPerAgent)}</span>
																<a href="javascript:void(0)"><i class="expand" id="expandAndCollapse"></i></a>			
															</div>
														</td> 
														<td>
															<div class="pull-right">
																<span class="badge badge-info pull-right" ><span id="vuserlabel"><@spring.message "perfTest.configuration.availVuser"/></span><span id="vuserTotal"></span></span>
															</div> 
														</td>
													</tr>
													<tr id="processAndThreadPanel">
														<td colspan="2">
															<span id="processAndThreadPanelDiv">
															<div class="input-prepend">
																<span class="add-on" title='<@spring.message "perfTest.report.process"/>'><@spring.message "perfTest.report.process"/></span><input class="input required positiveNumber span1" type="text" id="processes" name="processes" value="${(test.processes)!0}"/> 
															</div>
															<div class="input-prepend">
																<span class="add-on" title='<@spring.message "perfTest.report.thread"/>'><@spring.message "perfTest.report.thread"/></span><input class="input required positiveNumber span1" type="text" id="threads" name="threads" value="${(test.threads)!0}"/>
															</div>
															</span> 
														</td>
													</tr>
												</table>
											</div>
										</div>
										
										<div class="control-group">
											<label for="scriptName" class="control-label"><@spring.message "perfTest.configuration.script"/></label>
											<div class="controls">
												<table style="width:100%">
													<colgroup>
														<col width="*"/>
														<col width="100px"/>
													</colgroup>
													<tr>
													<td>
														<select id="scriptName" class="required" name="scriptName">
															<option value="">---</option>
														<#if scriptList?? && scriptList?size &gt; 0> 
															<#list scriptList as scriptItem> 
																<#if  test?? && scriptItem.path == test.scriptName && test.createdUser.userId == currentUser.userId> 
																	<#assign isSelected = "selected"/> 
																<#else> 
																	<#if quickScript?? && quickScript == scriptItem.path>
																		<#assign isSelected = "selected"/> 
																	<#else>
																		<#assign isSelected = 	""/>
																	</#if> 
																</#if>
																<option value="${scriptItem.path}" ${isSelected}>${scriptItem.path}</option> 
															</#list> 
														</#if>
														</select>
													</td>
													<td>
														<input type="hidden" id="scriptRevision" name="scriptRevision" value="${(test.scriptRevision)!-1}">
														<button class="btn btn-mini btn-info pull-right" type="button" id="showScript" style="margin-top:3px">
														REV:
														<#if test?? && test.scriptRevision != -1>
															${test.scriptRevision}
														<#else>
															HEAD
														</#if>
														</button>
													</td>
													</tr>
												</table> 
											</div> 
										</div>
										<div class="control-group">
											<label for="Script Resources" class="control-label"><@spring.message "perfTest.configuration.scriptResources"/></label>
											<div class="controls">
												<div class="div-resources read-only" id="scriptResources" readonly="readonly"></div>
											</div>
										</div>

										<div class="control-group">
											<label class="control-label"><@spring.message "perfTest.configuration.targetHost"/></label>
											<#if test?? && test.targetHosts??>
												<#assign targetHosts = test.targetHosts>
											<#elseif targetHostString??>
												<#assign targetHosts = targetHostString>
											<#else>
                                                <#assign targetHosts = "">
                                            </#if>
											<div class="controls">
												<#include "host.ftl">
											</div> 
										</div>
										<hr>
										<div class="control-group"> 
											<label class="control-label"> <input type="radio" id="durationChkbox" checked="true"> <@spring.message "perfTest.configuration.duration"/>
											</label>
											<div class="controls docs-input-sizes">
												<select class="select-item" id="hSelect"></select> : 
												<select class="select-item" id="mSelect"></select> : 
												<select class="select-item" id="sSelect"></select> &nbsp;&nbsp;
												<code>HH:MM:SS</code>
												<input type="hidden" id="duration" class="required positiveNumber" name="duration"
													value="${(test.duration)!60000}">
												<div id="durationSlider" class="slider" style="margin-left: 0; width: 250px"></div>
												<input id="hiddenDurationInput" class="span1 hide" data-slider="#durationSlider" data-max="39" data-min="1"
													data-step="1">

											</div>
										</div>
										<div class="control-group">
											<label for="runCount" class="control-label"> <input type="radio" id="runcountChkbox"> 
												<@spring.message "perfTest.configuration.runCount"/>
											</label>
											<div class="controls">
												<div class="input-append">
													<input type="text" 
														data-original-title="<@spring.message "perfTest.configuration.runCount"/>"
														data-content="<@spring.message "perfTest.configuration.runCount.help"/>"	
														rel="popover"												
														id="runCount" class="input span2" number_limit="${(maxRunCount)}" name="runCount"
														value="${(test.runCount)!0}"><span class="add-on"><@spring.message "perfTest.configuration.max"/> ${(maxRunCount)}</span>
												</div>
											</div>
										</div>
										<div class="control-group">
											<label for="ignoreSampleCount" class="control-label"> <@spring.message "perfTest.configuration.ignoreSampleCount"/> </label>
											<div class="controls">
												<input type="text" class="input required countNumber" 
													data-original-title="<@spring.message "perfTest.configuration.ignoreSampleCount"/>"
													data-content='<@spring.message "perfTest.configuration.ignoreSampleCount.help"/>'
													rel="popover"												
													id="ignoreSampleCount" name="ignoreSampleCount"
													value="${(test.ignoreSampleCount)!0}">
											</div>
										</div>
									</fieldset>
								</div>
							</div>
							<!-- end test content left -->
							
							<div class="span6">
								<div class="page-header">
									<label class="checkbox" style="margin-bottom: 0"> 
										<input type="checkbox" id="rampupCheckbox" name="useRampUp"
											<#if test?? && test.useRampUp?default(false) == true>checked</#if> 
										/>
										<h4>
											<@spring.message "perfTest.configuration.rampEnable"/>
										</h4>
									</label>
								</div>
								<table>
									<tr>
										<td style="width: 50%">
											<div class="form-horizontal form-horizontal-2">
												<fieldset>
													<div class="control-group">
														<label for="initProcesses" class="control-label"> <@spring.message "perfTest.configuration.initalProcesses"/> </label>
														<div class="controls">
															<input type="text" class="input input-mini required countNumber" id="initProcesses" name="initProcesses"
																value="${(test.initProcesses)!0}"/>
														</div>
													</div>
													<div class="control-group">
														<label for="processIncrement" class="control-label"> <@spring.message "perfTest.configuration.rampup"/> </label>
														<div class="controls">
															<input type="text" class="input input-mini required positiveNumber" id="processIncrement"
																name="processIncrement" value="${(test.processIncrement)!1}">
														</div>
													</div>
												</fieldset>
											</div>
										</td>
										<td>
											<div class="form-horizontal form-horizontal-2">
												<fieldset>
													<div class="control-group">
														<label for="initSleepTime" class="control-label"> <@spring.message "perfTest.configuration.initalSleepTime"/> </label>
														<div class="controls">
															<input type="text" class="input input-mini required countNumber" id="initSleepTime" name="initSleepTime"
																value="${(test.initSleepTime)!0}">
															<code>MS</code>
														</div>
													</div>
													<div class="control-group">
														<label for="processIncrementInterval" class="control-label"> 
															<@spring.message "perfTest.configuration.processesEvery"/> 
														</label>
														<div class="controls">
															<input type="text" class="input input-mini required positiveNumber" id="processIncrementInterval"
																name="processIncrementInterval" value="${(test.processIncrementInterval)!1000}">
															<code>MS</code>
														</div>
													</div>
												</fieldset>
											</div>
										</td>
									</tr>
								</table>
								<div class="page-header center" style="padding-bottom:10px;">
									<strong><@spring.message "perfTest.configuration.rampUpDes"/></strong>
								</div>
								<div id="rampChart" class="rampChart"></div>
							</div>
							<!-- end test content right -->
						</div>
					</div>
					<!-- end test content -->
					
					<div class="tab-pane" id="reportContent">
					</div>
					
					<div class="tab-pane" id="runningContent">
						<#include "runningDiv.ftl">
					</div>
					<!-- end running content -->
				</div>
				<!-- end tab content -->
			</div>
			<!-- end tabbable -->
			<input type="hidden" id="scheduleInput" name="scheduledTime" /> 
			<#if test??> 
				<input type="hidden" id="testStatus" name="status" value="${(test.status)}">
				<input type="hidden" id="testStatusType" name="statusType" value="${(test.status.category)}"> 
			<#else>
				<input type="hidden" id="testStatus" name="status" value="SAVED">
			</#if>
		</form>
		<#include "../common/copyright.ftl">
	</div>
	<!--end container-->

	<div class="modal fade" id="scheduleModal">
		<div class="modal-header">
			<a class="close" data-dismiss="modal">&times;</a>
			<h3>
				<@spring.message "perfTest.testRunning.scheduleTitle"/> <small class="errorColor"></small>
			</h3>
		</div>
		<div class="modal-body">
			<div class="form-horizontal">
				<fieldset>
					<div class="control-group">
						<label class="control-label"><@spring.message "perfTest.testRunning.schedule"/></label>
						<div class="controls form-inline">
							<input type="text" class="input span2" id="sDateInput" value="" readyonly>&nbsp; 
							<select id="shSelect" class="select-item"></select> : <select id="smSelect" class="select-item"></select>
							<code>HH:MM</code>
						</div>
					</div>
				</fieldset>
			</div>
		</div>
		<div class="modal-footer">
			<a class="btn btn-primary" id="runNowBtn"><@spring.message "perfTest.testRunning.runNow"/></a> <a class="btn btn-primary" id="addScheduleBtn"><@spring.message "perfTest.testRunning.schedule"/></a>
		</div>
	</div>

<script src="${req.getContextPath()}/plugins/datepicker/js/bootstrap-datepicker.js"></script>
<script src="${req.getContextPath()}/js/rampup.js"></script>
<script src="${req.getContextPath()}/js/bootstrap-slider.min.js"></script>
<script src="${req.getContextPath()}/js/queue.js"></script>
<script>
// vuser calc
${processthread_policy_script}

var jqplotObj;
var objTimer;
var test_tps_data = new Queue();
var durationMap = [];
	  
$(document).ready(function () {
	$.ajaxSetup({
		cache : false //close AJAX cache
	});
	initTags();
	initDuration();
	initChartData();
	initScheduleDate();
	initThresholdChkBox();
	$("#tableTab a:first").tab('show');
	$("#testContent_tab a").tab('show');
	$("#processAndThreadPanel").hide();
	
	addValidation();
	bindEvent();
	updateScriptResources(true);
	updateVuserTotal();
	updateRampupChart();
	
	<#if test??>
		<#if test.status.category == "TESTING"> 
  			displayCfgAndTestRunning(); 
		<#elseif test.status.category == "FINISHED" || test.status.category == "STOP"> 
			displayCfgAndTestReport(); 
		<#else>
			displayCfgOnly(); 
		</#if>
	<#else>
		displayCfgOnly();
	</#if>
});

function initTags() {
	$("#tagString").select2({tags:[]});
}

function initScheduleDate() {
	var date = new Date();
	var year = date.getFullYear();
	var month = date.getMonth() + 1;
	var day = date.getDate();
	$("#sDateInput").val(year + "-" + (month < 10 ? "0" + month : month) + "-" + (day < 10 ? "0" + day : day));
	
	$('#sDateInput').datepicker({
		format : 'yyyy-mm-dd'
	});
}

function initDuration() {
	var sliderMax = 40;
	durationMap[0] = 0;
	
	for ( var i = 1; i <= sliderMax; i++) {
		if (i <= 10) {
			durationMap[i] = durationMap[i - 1] + 1;
		} else if (i <= 20) {
			durationMap[i] = durationMap[i - 1] + 5;
		} else if (i <= 32) { //untill 180 min
			durationMap[i] = durationMap[i - 1] + 10;
		} else if (i <= 38) { //360 min
			durationMap[i] = durationMap[i - 1] + 30;
		} else if (i <= 56) { //24 hours
			durationMap[i] = durationMap[i - 1] + 60;
		} else if (i <= 72) {
			durationMap[i] = durationMap[i - 1] + 60 * 6;
		} else if (i <= 78) {
			durationMap[i] = durationMap[i - 1] + 60 * 12;
		} else {
			durationMap[i] = durationMap[i - 1] + 60 * 24;
		}
	}
	
	for ( var i = 0; i <= sliderMax; i++) {
		if (durationMap[i] * 60000 == $("#duration").val()) {
			$("#hiddenDurationInput").val(i);
			break;
		}
	}
	
	$("#hSelect").append(getOption(7 + 1));
	$("#hSelect").change(getDurationMS);
	
	$("#mSelect").append(getOption(60));
	$("#mSelect").change(getDurationMS);
	
	$("#sSelect").append(getOption(60));
	$("#sSelect").change(getDurationMS);
	
	$("#shSelect").append(getOption(24));
	$("#smSelect").append(getOption(60));
	
	setDuration();
}

function addValidation() {
	$("#testContentForm").validate({
		rules : {
			testName : "required",
			agentCount : "required",
			vuserPerAgent : "required"
		},
	    messages: {
	        testName: "<@spring.message "perfTest.warning.testName"/>",
	        agentCount: "<@spring.message "perfTest.warning.agentNumber"/>",
	        vuserPerAgent: "<@spring.message "perfTest.warning.vuserPerAgent"/>"
	    },
		ignore : "", // make the validation on hidden input work
		errorClass : "help-inline",
		errorElement : "span",
		errorPlacement : function(error, element) {
			if (element.next().attr("class") == "add-on") {
				error.insertAfter(element.next());
			} else {
				error.insertAfter(element);
			}
		},
		highlight : function(element, errorClass, validClass) {
			$(element).parents('.control-group').addClass('error');
			$(element).parents('.control-group').removeClass('success');
		},
		unhighlight : function(element, errorClass, validClass) {
			$(element).parents('.control-group').removeClass('error');
			$(element).parents('.control-group').addClass('success');
		}
	});

	$("#vuserPerAgent").rules("add", {
		max:${(maxVuserPerAgent)}
	});
}

function bindEvent() {
	$('#testContentForm input').hover(function() {
		$(this).popover('show');
	});
	
	$("#scriptName").change(function(selected) {
		$("#showScript").val(selected);
		updateScriptResources(false);
	});
	
	$("#hiddenDurationInput").bind("slide", function(e) {
		$("#duration").val(durationMap[this.value] * 60000);
		setDuration();
		$("#duration").valid();
	});
	
	$("#saveScheduleBtn").click(function() {
		if (!$("#testContentForm").valid()) {
			return false;
		}
	});
	
	$("#saveTestBtn").click(function() {
		if (!$("#testContentForm").valid()) {
			return false;
		}
		$("#testStatus").val("SAVED");
		$("#scheduleInput").attr('name', '');
		return true;
	});
	
	$("#runNowBtn").click(function() {
		$("#scheduleModal").modal("hide");
		$("#scheduleModal small").html("");
		$("#scheduleInput").attr('name', '');
		$("#testStatus").val("READY");
		document.testContentForm.submit();
	});

	$("#addScheduleBtn").click(function() {
		if (checkEmptyByID("sDateInput")) {
			$("#scheduleModal small").html("<@spring.message "perfTest.detail.message.setScheduleDate"/>");
			return;
		}
	
		var timeStr = $("#sDateInput").val() + " " + $("#shSelect").val() + ":" + $("#smSelect").val() + ":0";
		var scheduledTime = new Date(timeStr.replace(/-/g, "/"));
		if (new Date() > scheduledTime) {
			$("#scheduleModal small").html("<@spring.message "perfTest.detail.message.errScheduleDate"/>");
			return;
		}
		$("#scheduleInput").val(scheduledTime);
		$("#scheduleModal").modal("hide");
		$("#scheduleModal small").html("");
		$("#testStatus").val("READY");
		document.testContentForm.submit();
	});

	$("#runcountChkbox").change(function() {
		if ($("#runcountChkbox").attr("checked") == "checked") {
			$("#threshold").val("R");
			$("#runCount").addClass("required");
			$("#runCount").addClass("positiveNumber");
			$("#durationChkbox").removeAttr("checked");
			$("#duration").removeClass("required");
			$("#duration").removeClass("positiveNumber");
			$("#duration").valid();
			$("#runCount").valid();
		}
	});
	
	$("#durationChkbox").change(function() {
		if ($("#durationChkbox").attr("checked") == "checked") {
			$("#threshold").val("D");
			$("#duration").addClass("required positiveNumber");
			$("#runcountChkbox").removeAttr("checked");
			$("#runCount").removeClass("required");
			$("#runCount").removeClass("positiveNumber");
			$("#duration").valid();
			$("#runCount").valid();
		}
	});
	
	$("#agentCount").change(function() {
		updateVuserTotal();
		$("#vuserPerAgent").validate();
	});
	
	$("#threads").change(function() {
		$("#vuserPerAgent").val($("#processes").val() * $("#threads").val());
		if ($("#vuserPerAgent").valid()) {
			updateVuserGraph();
			updateVuserTotal();
		}
	});
	
	$("#processes").change(function() {
		$("#vuserPerAgent").val($("#processes").val() * $("#threads").val());
		if ($("#vuserPerAgent").valid()) {
			updateVuserGraph();
			updateVuserTotal();
		}
	});
	
	$("#vuserPerAgent").change(function() {
		var vuserElement = $(this);
		var processCount = $("#processes").val();
		if (vuserElement.valid()) {
			var result = updateVuserPolicy(vuserElement.val());
			$(this).val(result[0] * result[1]);
			if (processCount != result[0]) {
				updateVuserGraph();
			}
			updateVuserTotal();
		}
	});
	
	$("#reportLnk").click(function() {
		$("#footer").hide();
		openReportDiv(function() {
			$("#footer").show();			
		});
	});
	
	$('#tableTab a').click(function(e) {
		var $this = $(this);
		if (!$this.hasClass("pull-right")) {
			e.preventDefault();
			$this.attr("tid");
			$this.tab('show');
		}
	});

	$("#showScript").click(function() {
		var currentScript = $("#scriptName").val();
		if (currentScript != "") {
			var scriptRevision = $("#scriptRevision").val();
			window.open("${req.getContextPath()}/script/detail/" + currentScript + "?r=" + scriptRevision, "scriptSource");
		}
	});
	
	$("#expandAndCollapse").click(function() {
		$(this).toggleClass("collapse");
		$("#processAndThreadPanelDiv").toggle();
		$("#processAndThreadPanel").toggle();
	});
	
	$("#durationSlider").mousedown(function() {
		$("#durationChkbox").click();
	});
	
	$("#runCount").focus(function() {
		$("#runcountChkbox").click();
	});
	
}

function updateVuserTotal() {
	var agtCount = $("#agentCount").val();
	var vcount = $("#vuserPerAgent").val();
	$("#vuserTotal").text(agtCount * vcount);
}

function initChartData() {
	for ( var i = 0; i < 60; i++) {
		test_tps_data.enQueue(0);
	}
}

function updateScriptResources(first) {
	$('#messageDiv').ajaxSend(function(e, xhr, settings) {
		var url = settings.url;
		if (url.indexOf("refresh") == 0) {
			showInformation("<@spring.message "perfTest.detail.message.updateResource"/>");
		}
	});
	$.ajax({
		url : "${req.getContextPath()}/perftest/getResourcesOnScriptFolder",
		dataType : 'json',
		data : {
			'scriptPath' : $("#scriptName").val(),
			'r' : $("#scriptRevision").val()
		},
		success : function(res) {
			var html = "";
			var len = res.resources.length;
			if (first != true) {
				$(".div-host").html("");
				$("#hostsHidden").val(res.targetHosts);
				initHosts();
			}
			for ( var i = 0; i < len; i++) {
				var value = res.resources[i];
				html = html + "<div class='resource'>" + value + "</div><br/>";
			}
			$("#scriptResources").html(html);
		},
		error : function() {
			showErrorMsg("<@spring.message "common.error.error"/>");
			return false;
		}
	});
}

function updateVuserPolicy(vuser) {
	var processCount = getProcessCount(vuser);
	var threadCount = getThreadCount(vuser);
	$('#processes').val(processCount);
	$('#threads').val(threadCount);

	return [ processCount, threadCount ];
}

function updateVuserGraph() {
	//if ramp-up chart is not enabled, update init process count as total 
	if ($("#rampupCheckbox")[0].checked) {
		updateRampupChart();
	}
}

function initThresholdChkBox() {
	if ($("#threshold").val() == "R") { //runcount
		$("#runcountChkbox").attr("checked", "checked");
		$("#durationChkbox").removeAttr("checked");
	} else { //duration
		$("#durationChkbox").attr("checked", "checked");
		$("#runcountChkbox").removeAttr("checked");
	}
}

function setDuration() {
	var duration = $("#duration").val();
	var durationInSec = parseInt(duration / 1000);
	var durationH = parseInt((durationInSec % (60 * 60 * 24)) / 3600);
	var durationM = parseInt((durationInSec % 3600) / 60);
	var durationS = durationInSec % 60;

	$("#hSelect").val(durationH);
	$("#mSelect").val(durationM);
	$("#sSelect").val(durationS);
}

function getDurationMS() {
	var durationH = parseInt($("#hSelect").val());
	var durationM = parseInt($("#mSelect").val());
	var durationS = parseInt($("#sSelect").val());
	var durationMs = (durationS + durationM * 60 + durationH * 3600) * 1000;
	var durationObj = $("#duration");
	durationObj.val(durationMs);
	durationObj.valid(); //trigger validation
	return durationMs;
}

function toggleThreshold() {
	$("#runcountChkbox").toggle();
	$("#durationChkbox").toggle();
}

function getOption(cnt) {
	var contents = [];
	for (i = 0; i < cnt; i++) {
		contents.push("<option value='" + i + "'>" + i + "</option>");
	}
	return contents.join("\n");
}

function openReportDiv(onFinishHook) {
	$("#reportContent").load("${req.getContextPath()}/perftest/loadReportDiv?testId=" + $("#testId").val() + "&imgWidth=600",
		function() {
			drawChart('TPS', 'tpsDiv', $("#tpsData").val());
			if (onFinishHook !== undefined) {
				onFinishHook();
			}
		}
	);
}


function updateStatus(id, status_type, status_name, icon, deletable, stoppable, message) {
	if (status_type == "FINISHED" || status_type == "STOP_ON_ERROR" || status_type == "CANCELED") {
		isFinished = true;
	}
	if ($("#testStatusType").val() == status_type) {
		return;
	}
	var ballImg = $("#testStatus_img_id");

	$("#teststatus_pop_over").attr("data-original-title", status_name);
	$("#teststatus_pop_over").attr("data-content", message);

	$("#testStatusType").val(status_type);
	if (ballImg.attr("src") != "${req.getContextPath()}/img/ball/" + icon) {
		ballImg.attr("src", "${req.getContextPath()}/img/ball/" + icon);
	}

	if (status_type == "TESTING") {
		displayCfgAndTestRunning();
	} else if (status_type == "FINISHED" || status_type == "STOP_ON_ERROR" || status_type == "CANCELED") {
		displayCfgAndTestReport();
	} else {
		displayCfgOnly();
	}
}

var isFinished = false;
var testId = $('#testId').val();
// Wrap this function in a closure so we don't pollute the namespace
(function refreshContent() {
	var ids = [];
	if (testId == "" || isFinished) {
		return;
	}

	$.ajax({
		url : '${req.getContextPath()}/perftest/updateStatus',
		type : 'GET',
		data : {
			"ids" : testId
		},
		success : function(perfTestData) {
			perfTestData = eval(perfTestData);
			data = perfTestData.statusList
			for ( var i = 0; i < data.length; i++) {
				updateStatus(data[i].id, data[i].status_type, data[i].name, data[i].icon, data[i].deletable, data[i].stoppable, data[i].message);
			}
		},
		complete : function() {
			setTimeout(refreshContent, 5000);
		}
	});
})();

function displayCfgOnly() {
	$("#testContent_tab a").tab('show');
	$("#runningContent_tab").hide();
	$("#reportContent_tab").hide();
}

function displayCfgAndTestRunning() {
	$("#runningContent_tab").show();
	$("#runningContent_tab a").tab('show');
	$("#runningContent").show();
	$("#reportContent_tab").hide();
	objTimer = window.setInterval("refreshData()", 1000);
}

function displayCfgAndTestReport() {
	$("#footDiv").hide();
	$("#runningContent_tab").hide();
	$("#reportContent_tab").show();
	$("#reportContent_tab a").tab('show');
	openReportDiv(function() {
		$("#footDiv").show();
	});
	if (objTimer) {
		window.clearInterval(objTimer);
	}
}
</script>
	</body>
</html>
