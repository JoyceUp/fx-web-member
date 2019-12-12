{% extends '../../common/layouts/layout.tpl' %}

{% block css_assets %}
    {# 引入css #}
    <style>
        .user_info div{
            margin-top: 16px;
        }
        .user_info div .second_span{
            margin-top: 100px;
        }
        .position_info div{
            margin-top: 10px;
        }

        .info-attr-name {
            width: 20%; display:inline-block;text-align:right;padding-right:10px
        }
        .position-attr-name {
             display:inline-block;text-align:right;padding-right:10px
        }
    </style>
{% endblock %}
{% set sale_setting = Lang.select.sale %}
{% block js_assets %}
<script>
    var identity_type = new Object();
    {% for at in Lang.select.sale.identity_type %}
        identity_type[{{ at.value }}] = "{{ at.label }}";
    {% endfor %}

    var gender = new Object();
    {% for at in Lang.select.sale.gender %}
    gender[{{ at.value }}] ="{{ at.label }}";
    {% endfor %}
</script>
{% endblock %}

{% block content %}
    {# 内容 #}
    <div class="main_content">
        <div class="main_content_holder">
            <div id="fund">
                <div class="main_head">
                    <div class="main_head_unit">
                        {{ Lang.page_userinfo_title || "用户信息" }}
                    </div>
                    <div class="main_head_text required">

                    </div>
                </div>
                <div class="main_page_Info">
                    <div class="form">
                        <div class="form_input" style="padding-left: 80px">
                            <div>
                                <p>{{ Lang.form_text_base_info || "基本信息" }}</p>
                                <div  class="layui-row">
                                    <div class="layui-col-md4 layui-col-md-offset2" style="line-height: 30px">
                                       {# <p><span class="info-attr-name">{{ Lang.form_text_sales_no || "销售编号" }}:</span><span>{{ datas.employee_no }}</span></p>#}
                                        <p><span class="info-attr-name">{{ Lang.form_placeholder_name || "姓名" }}:</span><span>{{ datas.full_name }}</span></p>
                                        <p><span class="info-attr-name">{{ Lang.form_text_identity_type || "证件类型" }}:</span><span>{{ sale_setting.identity_type[datas.identity_type] }}</span></p>
                                        <p><span class="info-attr-name">{{ Lang.form_text_mobile || "手机号码" }}:</span><span>{{ datas.mobile }}</span></p>
                                        <p><span class="info-attr-name">{{ Lang.form_text_date_of_birth || "出生日期" }}:</span><span>{{ datas.date_of_birth| dateOfBirth}}</span></p>
                                        <p><span class="info-attr-name">{{ Lang.form_text_gmt_create || "创建时间" }}:</span><span>{{ datas.gmt_create }}</span></p>
                                    </div>

                                    <div  class="layui-col-md4 layui-col-md-offset1" style="line-height: 30px">
                                        <p><span class="info-attr-name">{{ Lang.form_text_sales_account_no || "销售账号" }}:</span><span>{{ datas.account_no }}</span></p>
                                        <p><span class="info-attr-name">{{ Lang.form_text_sex || "性别" }}:</span><span>{{ sale_setting.gender[datas.gender] }}</span></p>
                                        <p><span class="info-attr-name">{{ Lang.form_text_identity_no || "证件号码" }}:</span><span>{{ datas.identity_no }}</span></p>
                                        <p><span class="info-attr-name">{{ Lang.form_text_email || "电子邮箱" }}:</span><span>{{ datas.email }}</span></p>
                                        <p><span class="info-attr-name">{{ Lang.form_text_gmt_modified || "更新时间" }}:</span><span>{{ datas.gmt_modified }}</span></p>
                                    </div>
                                </div>
                            </div>
                            <div class="layui-row">
                                <p>{{ Lang.form_text_position_info || "职位信息" }}</p>
                                <div class="layui-row" style="margin-left: 60px;margin-top: 20px">
                                    {% for position in datas.position %}
                                        <div class="layui-col-md2 layui-col-md-offset1" style="margin-left:130px;line-height: 30px">
                                            <p><span class="position-attr-name">{{ Lang.form_text_company || "公司" }}: </span><span>{{ position.company }}</span></p>
                                            <p><span class="position-attr-name">{{ Lang.form_text_department || "部门" }}:</span><span>{{ position.department }}</span></p>
                                            <p><span class="position-attr-name">{{ Lang.form_text_team || "组别" }}:</span><span>{{ position.team }}</span></p>
                                            <p><span class="position-attr-name">{{ Lang.form_text_position_name || "职位" }}:</span><span>{{ position.name }}</span></p>
                                        </div>
                                    {% endfor %}
                                    {% if datas == null || datas.position == null %}
                                        <div class="layui-col-md2 layui-col-md-offset1" style="margin-left:130px;line-height: 30px">
                                            <p><span class="position-attr-name">{{ Lang.form_text_company || "公司" }}: </span><span>{{ position.company }}</span></p>
                                            <p><span class="position-attr-name">{{ Lang.form_text_department || "部门" }}:</span><span>{{ position.department }}</span></p>
                                            <p><span class="position-attr-name">{{ Lang.form_text_team || "组别" }}:</span><span>{{ position.team }}</span></p>
                                            <p><span class="position-attr-name">{{ Lang.form_text_position_name || "职位" }}:</span><span>{{ position.name }}</span></p>
                                        </div>
                                    {% endif %}
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
{% endblock %}

