{% extends '../../common/layouts/layout.tpl' %}

{% block css_assets %}
    {# 引入css #}

{% endblock %}

{% set myselect =  Lang.select.member.customer %}
{% set registerInfo =  Lang.select.member.register %}

{% block js_assets %}

    <script>

        /*
        * upload    控件
        * btn_id    按钮id
        * img_id    展示id
        * hidden_id 实际参数id
        * msg_id    提示id
        * */
        function createUploadImgControls(upload, btn_id, img_id, hidden_id, msg_id) {
            var img_base64;
            var uploadInst = upload.render({
                elem: '#' + btn_id
                , url: '/common/upload/'
                ,data: {role_type: window.user.role_type, role_id: window.user.user_id}
                ,size: 2048 //限制文件大小，单位 KB
                ,exts: 'png|jpg|jpeg' //只允许上传png|jpg
                ,before: function(obj){
                    //预读本地文件示例，不支持ie8
                    layer.load(2); //上传loading
                    obj.preview(function(index, file, result){
                        img_base64 = result;
                    });
                }
                ,done: function(res){
                    layer.closeAll('loading'); //关闭loading
                    //如果上传失败
                    if(res.code > 0){
                        return layer.msg('{{ Lang.msg_upload_error || "上传失败" }}');
                    }
                    //上传成功
                    if(res.status === 200){
                        jQuery("#" + hidden_id).val(JSON.parse(res.datas).id);
                        $('#' + img_id).attr('src', img_base64); //图片链接（base64）
                    }
                }
                ,error: function(){
                    layer.closeAll('loading'); //关闭loading
                    //演示失败状态，并实现重传
                    var txt_upload = $('#' + msg_id);
                    txt_upload.html('<span style="color: #FF5722;">{{ Lang.msg_upload_error || "上传失败" }}</span> <a class="layui-btn layui-btn-mini demo-reload">{{ Lang.msg_retry || "重试" }}</a>');
                    txt_upload.find('.demo-reload').on('click', function(){
                        uploadInst.upload();
                    });
                }
            });
        }
        layui.use('upload', function(){
            var $ = layui.jquery
                ,upload = layui.upload;
            var img_base64;
            //普通图片上传
            //证件正面
            createUploadImgControls(upload, "btn_upload1", "img_upload1", "identity1_path", "txt_upload1");
            //证件反面
            createUploadImgControls(upload, "btn_upload2", "img_upload2", "identity2_path", "txt_upload2");
            //居住信息
            createUploadImgControls(upload, "btn_upload", "img_upload", "address_path", "txt_upload");
        });


        layui.use(['form'], function(){
            var form = layui.form
                ,layer = layui.layer

            //自定义验证规则
            form.verify({

                mobile: function(value){
                    if(value.trim() != '' && !mobileReg.test(value)){
                        return '{{ Lang.validate_mobile_format_error || "手机号码格式有误" }}';
                    }
                },
                country: function(value){
                    if(value.length === 0 || (/^\s+$/.test(value))){
                        return '{{ Lang.validate_country_not_null || "请选择居住国家" }}';
                    }
                },
                city: function(value){
                    if(value.length === 0 || (/^\s+$/.test(value))){
                        return '{{ Lang.validate_city_not_null || "请输入城市" }}';
                    }
                },
                address: function(value){
                    if(value.length === 0 || (/^\s+$/.test(value))){
                        return '{{ Lang.validate_address_not_null || "请输入居住地址" }}';
                    }
                },
                zip_code: function(value){
                    if(value.length === 0 || (/^\s+$/.test(value))){
                        return '{{ Lang.validate_zip_code_not_null || "请输入邮政编码" }}';
                    };
                    if(!(/^\d{6}$/.test(value))){
                        return '{{ Lang.validate_zip_format_error || "邮政编码有误" }}';
                    };
                },
                path: function(value){
                    if(value.length === 0){
                        return '{{ Lang.validate_path_not_null || "请上传地址证明" }}';
                    }
                }
            });



            //监听提交
            form.on('submit(from_submit_1)', function(data){

                data.field.id = window.user.user_id;

                jQuery.ajax({
                    url:"/member/customer/userinfo/update",
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
            form.on('submit(from_submit_2)', function(data){

                var d = {
                    id: window.user.user_id,
                    "identity1_path": data.field.identity1_path,
                    "identity2_path": data.field.identity2_path
                };
                jQuery.ajax({
                    url:"/member/customer/identity/update",
                    type: "POST",
                    dataType: "JSON",
                    data: JSON.stringify(d),
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
            form.on('submit(from_submit_3)', function(data){

                data.field.id = window.user.user_id;
                jQuery.ajax({
                    url:"/member/customer/address/update",
                    type: "POST",
                    dataType: "JSON",
                    data: JSON.stringify(data.field),
                    async: true,
                    error: function (result, status) {
                        layer.msg("{{ Lang.msg_update_success || "修改成功" }}", {
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

    <div class="main_content">
        <div class="main_content_holder">
            <div id="fund">
                <div class="main_head">
                    <div class="main_head_unit">
                        {{ Lang.page_user_userinfo_title || "个人信息" }}
                    </div>
                    <div class="main_head_text required"></div>
                </div>


                <div class="main_page_Info">
                    <div class="form">
                        <div class="form_input">

                            <div class="layui-tab">
                                <ul class="layui-tab-title">
                                    <li class="layui-this">{{ Lang.form_text_base_info || "基本信息" }}</li>
                                    <li>{{ Lang.form_text_identity_info || "身份信息" }}</li>
                                    <li>{{ Lang.form_text_address_info || "居住信息" }}</li>
                                </ul>
                                <div class="layui-tab-content">

                                    <div class="layui-tab-item layui-show">
                                        <form class="layui-form" action="">

                                            <div class="layui-form-item">
                                                <label class="layui-form-label">{{ Lang.form_text_family_name || "姓" }}:</label>
                                                <div class="layui-input-inline">
                                                    <div class="layui-form-mid">{{ datas.basic.family_name }}</div>
                                                </div>

                                                <label class="layui-form-label">{{ Lang.form_text_given_name || "名" }}:</label>
                                                <div class="layui-input-inline">
                                                    <div class="layui-form-mid">{{ datas.basic.given_name }}</div>
                                                </div>
                                            </div>

                                            <div class="layui-form-item">
                                                <label class="layui-form-label">{{ Lang.form_text_gender || "称呼" }}:</label>
                                                <div class="layui-input-inline">
                                                    <div class="layui-form-mid">
                                                        {% for item in registerInfo.gender %}
                                                            {% if datas.basic.gender === item.value %}
                                                                {{ item.label }}
                                                            {% endif %}
                                                        {% endfor %}
                                                    </div>
                                                </div>

                                                <label class="layui-form-label">{{ Lang.form_text_date_of_birth || "出生日期" }}:</label>
                                                <div class="layui-input-inline">
                                                    <div class="layui-form-mid">{{ datas.basic.date_of_birth | date('Y-m-d', -480) }}</div>
                                                </div>
                                            </div>

                                            <div class="layui-form-item">
                                                <label class="layui-form-label">{{ Lang.form_text_email || "电子邮箱" }}:</label>
                                                <div class="layui-input-inline">
                                                    <div class="layui-form-mid">{{ datas.basic.email }}</div>
                                                </div>

                                                <label class="layui-form-label">{{ Lang.form_text_mobile || "手机号码" }}:</label>
                                                <div class="layui-input-inline">
                                                    <input value="{{ datas.basic.mobile }}" type="text" name="mobile" lay-verify="mobile" autocomplete="off" placeholder="{{ form_placeholder_mobile }}" class="layui-input">
                                                </div>
                                            </div>

                                            <div class="layui-form-item">
                                                <div class="layui-input-block">
                                                    <button class="layui-btn" lay-submit="" lay-filter="from_submit_1" onclick="javascript:return false;">{{ Lang.btn_save || "保存" }}</button>
                                                </div>
                                            </div>
                                        </form>

                                        <div class="from_alert">
                                            <h3>{{ Lang.page_msg_h3 || "提示：" }}</h3>
                                            <p>{{ Lang.page_user_userinfo_basics_msg_txt || "为了保障您的资金安全及权益，我们不允许主动修改您的姓名及出生日期等资料。如果您确实需要对以下内容进行修改，请提供必须的证明文件（如结婚证明，姓名更改通知或离婚判决书等），将证明发送至我们的客户服务邮箱service@rtfgroups.com，邮件标题请注明为：“账户个人资料修改+您的账户编号”，或者致电我们的客服热线：400-002-8180，我们的客服人员会协助您完成操作。" }}</p>
                                        </div>

                                    </div>
                                    <div class="layui-tab-item">
                                        <div class="form">
                                            <form class="layui-form" action="">

                                                <div class="layui-form-item">
                                                    <label class="layui-form-label">{{ Lang.form_text_identity_type || "证件类型" }}:</label>
                                                    <div class="layui-input-inline">
                                                        <div class="layui-form-mid">
                                                            {% for item in registerInfo.identity_type %}
                                                                {% if datas.identity.identity_type === item.value %}
                                                                    {{ item.label }}
                                                                {% endif %}
                                                            {% endfor %}
                                                        </div>
                                                    </div>

                                                    <label class="layui-form-label">{{ Lang.form_text_identity_no || "证件号码" }}:</label>
                                                    <div class="layui-input-inline">
                                                        <div class="layui-form-mid">{{ datas.identity.identity_no | hideIdentityNo(datas.identity.identity_type) }}</div>
                                                    </div>
                                                </div>

                                                <div class="layui-form-item">
                                                    <label class="layui-form-label">{{ Lang.form_text_identity1_path || "证件正面" }}:</label>
                                                    <div class="layui-input-inline">
                                                        <div class="layui-upload">
                                                            <button type="button" class="layui-btn" id="btn_upload1" onclick="javascript:return false;">{{ Lang.btn_uploadImg || "上传图片" }}</button>
                                                            <div class="layui-upload-list">
                                                                <img style="width:192px;height:132px" id="img_upload1" src="/assets/member/images/pic.png" onload="javascript:getImages(this,'{{ datas.identity.identity1_path }}')" />
                                                                <p id="txt_upload1">{{ Lang.form_text_upload_img_limit || " 目前只支持png、jpg格式，大小控制在2MB之内 " }}</p>
                                                            </div>
                                                        </div>
                                                        <input type="hidden" id="identity1_path" name="identity1_path" lay-verify="path" value="{{ datas.identity.identity1_path }}" />
                                                    </div>
                                                    <label class="layui-form-label">{{ Lang.form_text_identity2_path || "证件反面" }}:</label>
                                                    <div class="layui-input-inline">
                                                        <div class="layui-upload">
                                                            <button type="button" class="layui-btn" id="btn_upload2" onclick="javascript:return false;">{{ Lang.btn_uploadImg || "上传图片" }}</button>
                                                            <div class="layui-upload-list">
                                                                <img style="width:192px;height:132px" id="img_upload2" src="/assets/member/images/pic.png" onload="javascript:getImages(this,'{{ datas.identity.identity2_path }}')" />
                                                                <p id="txt_upload2">{{ Lang.form_text_upload_img_limit || " 目前只支持png、jpg格式，大小控制在2MB之内 " }}</p>
                                                            </div>
                                                        </div>
                                                        <input type="hidden" id="identity2_path" name="identity2_path" lay-verify="path" value="{{ datas.identity.identity2_path }}" />
                                                    </div>
                                                </div>
                                                <div class="layui-form-item">
                                                    <div class="layui-input-block">
                                                        <button class="layui-btn" lay-submit="" lay-filter="from_submit_2" onclick="javascript:return false;">{{ Lang.btn_save || "保存" }}</button>
                                                    </div>
                                                </div>
                                            </form>
                                        </div>
                                        <div class="from_alert">
                                            {{ Lang.page_msg_h3 || "提示：" }}
                                            <p>{{ Lang.page_user_userinfo_id_msg_txt || "为了保障您的资金安全及权益，我们不允许主动修改您的身份信息。如果您确实需要对以下内容进行修改，请提供必须的证明文件（如结婚证明，姓名更改通知或离婚判决书等），将证明发送至我们的客户服务邮箱service@rtfgroups.com，邮件标题请注明为：“账户个人资料修改+您的账户编号”，或者致电我们的客服热线：400-002-8180，我们的客服人员会协助您完成操作。" }}</p>
                                        </div>
                                    </div>
                                    <div class="layui-tab-item">
                                        <div class="form">

                                            <form class="layui-form" action="">

                                                <div class="layui-form-item">
                                                    <label class="layui-form-label"><i>*</i>{{ Lang.form_text_country || "国家" }}:</label>
                                                    <div class="layui-input-inline">
                                                        <select name="country" lay-verify="country">
                                                            <option value="">{{ Lang.form_select_invite_type || "请选择" }}</option>

                                                            {% for item in Lang.select.common.address.countries %}
                                                                {% if datas.address.country === item[1] %}
                                                                    <option value="{{ item[1] }}" selected="selected">{{ item[1] }}</option>
                                                                {% else %}
                                                                    <option value="{{ item[1] }}">{{ item[1] }}</option>
                                                                {% endif %}
                                                            {% endfor %}
                                                        </select>
                                                    </div>

                                                    <label class="layui-form-label"><i>*</i>{{ Lang.form_text_city || "城市" }}:</label>
                                                    <div class="layui-input-inline">
                                                        <input value="{{ datas.address.city }}" type="text" name="city" lay-verify="city" autocomplete="off" placeholder="{{ form_placeholder_city }}" class="layui-input">
                                                    </div>
                                                </div>

                                                <div class="layui-form-item">
                                                    <label class="layui-form-label"><i>*</i>{{ Lang.form_text_address || "居住地址" }}:</label>
                                                    <div class="layui-input-inline">
                                                        <input value="{{ datas.address.address }}" type="text" name="address" lay-verify="address" autocomplete="off" placeholder="{{ form_placeholder_address }}" class="layui-input">
                                                    </div>
                                                    <label class="layui-form-label"><i>*</i>{{ Lang.form_text_zip_code || "邮政编码" }}:</label>
                                                    <div class="layui-input-inline">
                                                        <input value="{{ datas.address.zip_code }}" type="text" name="zip_code" lay-verify="zip_code" autocomplete="off" placeholder="{{ form_placeholder_zip_code }}" class="layui-input">
                                                    </div>
                                                </div>
                                                <div class="layui-form-item">
                                                    <label class="layui-form-label"><i>*</i>{{ Lang.form_label_address || "地址证明" }}:</label>
                                                    <div class="layui-input-block">
                                                        <div class="layui-upload">
                                                            <button type="button" class="layui-btn" id="btn_upload" onclick="javascript:return false;">{{ Lang.btn_uploadImg || "上传图片" }}</button>
                                                            <div class="layui-upload-list">
                                                                <img class="layui-upload-img" id="img_upload" src="/assets/member/images/pic.png" onload="javascript:getImages(this, '{{ datas.address.path }}')" />
                                                                <p id="txt_upload">{{ Lang.form_text_upload_img_limit || " 目前只支持png、jpg格式，大小控制在2MB之内 " }}</p>
                                                            </div>
                                                        </div>
                                                        <input type="hidden" id="address_path" name="path" lay-verify="path" value="{{ datas.address.path }}" />
                                                    </div>
                                                </div>

                                                <div class="layui-form-item">
                                                    <div class="layui-input-block">
                                                        <button class="layui-btn" lay-submit="" lay-filter="from_submit_3" onclick="javascript:return false;">{{ Lang.btn_save || "保存" }}</button>

                                                    </div>
                                                </div>
                                            </form>

                                        </div>

                                        <div class="from_alert">
                                            {{ Lang.page_msg_h3 || "提示：" }}
                                            <p>{{ Lang.page_user_userinfo_location_msg_txt1 || "1.Real Time Futures监管要求您必须提供一份有效的地址信息，否则无法正常出金。" }}</p>
                                            <p>{{ Lang.page_user_userinfo_location_msg_txt2 || "2.地址证明包括（任选其一即可）： 户口本/有效期内的护照或驾照或社保卡/最近3个月内的水电煤气账单或银行卡账单。" }}</p>

                                        </div>


                                    </div>
                                </div>
                            </div>


                        </div>
                    </div>
                </div>


            </div>
        </div>
    </div>



    <script>


        layui.use('element', function () {
            var element = layui.element;

            //…
        });
    </script>

{% endblock %}


