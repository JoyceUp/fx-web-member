{% extends '../../common/layouts/layout.tpl' %}
{% block content %}

			<div class="main_content">
				<div class="main_content_holder">
					<div id="fund">
						<div class="main_head">
							<div class="main_head_unit">
								{{ Lang.page_account_append_info_title || "创建新账户" }}
							</div>
							<div class="main_head_text required"></div>
						</div>
						<div class="main_page_Info">
							<div class="form">
								<div class="form_input">
									<div class="from_alert">
										<h3>{{ Lang.page_msg_h3 || "提示：" }}</h3>
										<p>{{ Lang.page_account_append_msg_txt || "系统将使用您第一次开立账号时所登记的资料，重新开立一个全新的账号，请确保您有足够的资金去维持新账号。" }}</p>
									</div>
									<form class="layui-form form w400" action="">
										<div class="layui-form-item">
											<label class="layui-form-label"><i>*</i>{{ Lang.form_placeholder_account_type || "账户类型" }}</label>
											<div class="layui-input-block">
												<select id="account_type" style="width: 240px"name="account_type" lay-verify="NotBlank" msg="{{ Lang.validate_account_type_not_chose || "请选择账户类型" }}">
													<option value="">{{ Lang.form_select_invite_type || "请选择" }}</option>
                                                    {% for at in Lang.select.member.account.account_type %}
                                                    {% for item in account_type %}
														{% if item == at.value %}
														<option value="{{ at.value }}">{{ at.label }}</option>
														{% endif %}
                                                    {% endfor %}
                                                    {% endfor %}
												</select>
											</div>
										</div>

										<div class="layui-form-item">
											<label class="layui-form-label"><i>*</i>{{ Lang.table_leverage || "杠杆比例" }}</label>
											<div class="layui-input-block">
												<select style="width: 240px" name="leverage" id="leverage" lay-verify="NotBlank" msg="{{ Lang.validate_account_leverage_not_chose || "请选杠杆比例" }}">
													<option value="50">1:50</option>
													<option value="100">1:100</option>
													<option value="200">1:200</option>
													<option value="400">1:400</option>
												</select>
											</div>
										</div>

										<div class="layui-form-item mt50">
											<div class="layui-input-block">
												<button class="layui-btn" lay-submit="" lay-filter="sub_btn" onclick="javascript:return false;">{{ Lang.btn_sub || "提交" || "提交" }}</button>
											</div>
										</div>
									</form>

								</div>
							</div>
						</div>
					</div>
				</div>
			</div>

{% endblock %}

{% block js_assets %}
	<script>
        layui.use(['form'], function(){
            var form = layui.form
                ,layer = layui.layer;

            form.verify({
                NotBlank: function(value, item){ //value：表单的值、item：表单的DOM对象
                    if(!value){
                        return $(item).attr("msg");
                    }
                }
            });

            var submit_f = false;
            //监听提交
            form.on('submit(sub_btn)', function(data){
                if(submit_f){
                    return false;
                }
                submit_f = true;
                $.ajax({
                    url: "/member/account/append_account",
                    async: true,
                    data: data.field,
                    type: "post",
                    dataType: "json",
                    contentType: "application/x-www-form-urlencoded;charset=UTF-8",
                    success: function (data) {
                        submit_f = false;
                        if (data.status == 200) {
                            layer.alert("{{ Lang.alert_register_success1 || "新账户注册成功，MT4账号：" }}"+JSON.parse(data.datas).account_no+"<br/>" +
								"{{ Lang.alert_register_success2 || "密码已发送至您的邮箱中" }}", {
                                title: '{{ Lang.page_text_info || "信息：" }}'
                            });
                        }else{
                            layer.alert(data.msg, {
                                title: '{{ Lang.page_text_info || "信息：" }}'
                            });
                        }
                    },
                    error: function (jqXHR, textStatus, errorThrown) {
                    }
                });
                return false;
            });

        });

	</script>
{% endblock %}