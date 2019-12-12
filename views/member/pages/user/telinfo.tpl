{% extends '../../common/layouts/layout.tpl' %}

{% block css_assets %}
    {# 引入css #}
{% endblock %}

{% block js_assets %}
    {# 引入js #}

    <script>
        layui.use('form', function () {
            var form = layui.form;

            //自定义验证规则
            form.verify({
                card_no: function (value) {
                    if (value.length === 0 || (/^\s+$/.test(value))) {
                        return '{{ Lang.validate_card_no_not_null || "请填写银行卡号" }}';
                    }
                    if (!(/^(\d)*$/.test(value))) {
                        return '{{ Lang.validate_card_no_only_number || "银行卡号只能输入数字" }}';
                    }
                },
                onlyEn: function(value, item) {
                    if(!value){
                        return $(item).attr("msg");
                    }

                    if(/[\u4E00-\u9FA5]/i.test(value)){
                        return '{{ Lang.validate_unchinese || "请输入非中文" }}'
                    }
                }
            });

            //监听提交
            form.on('submit(formSubmit)', function (data) {

                var url = (data.field.id && data.field.id.length > 0)?"/member/customer/telinfo/update":"/member/customer/telinfo/add";
                jQuery.ajax({
                    url: url,
                    type: "POST",
                    dataType: "JSON",
                    data: JSON.stringify(data.field),
                    async: true,
                    error: function (result, status) {
                        layer.msg(result.msg, {
                            icon: 2
                        });
                        return false;
                    },
                    success: function (result, status) {
                        if(result.status === 200) {
                            layer.msg("{{ Lang.msg_update_success || "修改成功" }}", {
                                icon: 1
                            });
                        }
                        else
                        {
                            layer.msg(result.msg, {
                                icon: 0
                            });

                        }
                        return false;
                    },
                    contentType: "application/json; charset=\"utf-8\""
                });

                return false;
            });
        });
    </script>

{% endblock %}

{% block content %}
    {# 内容 #}
    <div class="main_content">
        <div class="main_content_holder">
            <div id="fund">
                <div class="main_head">
                    <div class="main_head_unit">
                        {{ Lang.page_user_telinfo_title || "电汇信息" }}
                    </div>
                    <div class="main_head_text required">

                    </div>
                </div>
                <div class="main_page_Info">
                    <div class="form">
                        <div class="form_input">

                            <div class="form">

                                {#注意要把name改成相关的字段名#}
                                <form class="layui-form form w500" action="">
                                    <div class="layui-form-item">
                                        <label class="layui-form-label"><i>*</i>{{ Lang.form_label_card_no || "银行卡号" }}：</label>
                                        <div class="layui-input-block">
                                            <input type="hidden" name="id" value="{{ datas.id }}" />
                                            <input type="text" name="card_no" lay-verify="card_no"
                                                   autocomplete="off" class="layui-input" value="{{ datas.card_no }}"/>
                                        </div>
                                    </div>
                                    <div class="layui-form-item">
                                        <label class="layui-form-label"><i>*</i>{{ Lang.form_label_card_user_name || "银行账户户名" }}：</label>
                                        <div class="layui-input-block">
                                            <input type="text" name="card_user_name" lay-verify="onlyEn" msg="{{ Lang.validate_card_user_name_not_null || "银行账户户名不能为空" }}"
                                                   autocomplete="off" class="layui-input"
                                                   value="{{ datas.card_user_name }}"/>
                                        </div>
                                    </div>
                                    <div class="layui-form-item">
                                        <label class="layui-form-label"><i>*</i>{{ Lang.form_label_bank_name || "银行名称" }}：</label>
                                        <div class="layui-input-block">
                                            <input type="text" name="bank_name" lay-verify="onlyEn" msg="{{ Lang.validate_bank_name_not_null || "银行名称不能为空" }}"
                                                   autocomplete="off" class="layui-input"
                                                   value="{{ datas.bank_name }}"/>
                                        </div>
                                    </div>

                                    <div class="layui-form-item">
                                        <label class="layui-form-label"><i>*</i>{{ Lang.form_label_bank_country || "银行国家" }}：</label>
                                        <div class="layui-input-block">
                                            <input type="text" name="country" lay-verify="onlyEn" msg="{{ Lang.validate_bank_country_not_null || "银行国家不能为空" }}"
                                                   autocomplete="off" class="layui-input" value="{{ datas.country }}"/>
                                        </div>
                                    </div>
                                    <div class="layui-form-item">
                                        <label class="layui-form-label"><i>*</i>{{ Lang.form_label_bank_province || "地区（省）" }}：</label>
                                        <div class="layui-input-block">
                                            <input type="text" name="province" lay-verify="onlyEn" msg="{{ Lang.validate_bank_province_not_null || "地区（省）不能为空" }}"
                                                   autocomplete="off" class="layui-input" value="{{ datas.province }}"/>
                                        </div>
                                    </div>
                                    <div class="layui-form-item">
                                        <label class="layui-form-label"><i>*</i>{{ Lang.form_label_bank_city || "地区（市）" }}：</label>
                                        <div class="layui-input-block">
                                            <input type="text" name="city" lay-verify="onlyEn" msg="{{ Lang.validate_bank_city_not_null || "地区（市）不能为空" }}"
                                                   autocomplete="off" class="layui-input" value="{{ datas.city }}"/>
                                        </div>
                                    </div>

                                    <div class="layui-form-item">
                                        <label class="layui-form-label"><i>*</i>{{ Lang.form_label_branch_name || "银行开户行" }}：</label>
                                        <div class="layui-input-block">
                                            <input type="text" name="branch_name" lay-verify="onlyEn" msg="{{ Lang.validate_branch_name_not_null || "银行开户行不能为空" }}"
                                                   autocomplete="off" class="layui-input"
                                                   value="{{ datas.branch_name }}"/>
                                        </div>
                                    </div>

                                    <div class="layui-form-item">
                                        <label class="layui-form-label"><i>*</i>{{ Lang.form_label_branch_address || "开户行地址" }}：</label>
                                        <div class="layui-input-block">
                                            <input type="text" name="branch_address" lay-verify="onlyEn" msg="{{ Lang.validate_branch_address_not_null || "开户行地址不能为空" }}"
                                                   autocomplete="off" class="layui-input"
                                                   value="{{ datas.branch_address }}"/>
                                        </div>
                                    </div>

                                    <div class="layui-form-item">
                                        <label class="layui-form-label"><i>*</i>{{ Lang.form_label_branch_swift_code || "国际汇款代码" }}：</label>
                                        <div class="layui-input-block">
                                            <input type="text" name="branch_swift_code" lay-verify="onlyEn" msg="{{ Lang.validate_branch_swift_code_not_null || "国际汇款代码不能为空" }}"
                                                   autocomplete="off" class="layui-input"
                                                   value="{{ datas.branch_swift_code }}"/>
                                        </div>
                                    </div>

                                    <div class="layui-form-item mt50">
                                        <div class="layui-input-block">
                                            <button class="layui-btn" lay-submit lay-filter="formSubmit" onclick="javascript:return false;">{{ Lang.btn_sub || "提交" || "提交" }}</button>

                                        </div>
                                    </div>
                                </form>

                            </div>

                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
{% endblock %}

