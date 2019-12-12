<style>
    .reg-title-2 span{
        font-size:14px;
        color:#999;
    }
</style>

<div class="register">
    <div class="register-title">
        <span>1</span>/3  {{ Lang.page_register_step_title || "真实账户注册" }}
    </div>
    <div class="register-form">
        <p class="reg-title-1">{{ Lang.form_text_three_minutes_span || " 完成注册预计需要3分钟 " }}</p>
        <p class="reg-title-2">{{ Lang.form_text_base_info_ || "基础信息" }}<span>{{ Lang.form_text_basic_span || " （邮箱是您接收通知和交易信息的重要渠道，请认真填写。） " }}</span></p>
        <form class="layui-form" action="">
            <div class="layui-row">
                <div class="layui-col-md5 layui-col-xs12">
                    <div class="layui-form-item">
                        <label class="layui-form-label"><i>*</i>{{ Lang.form_text_gender || "称呼" }}:</label>
                        <div class="layui-input-block">
                            <select name="gender" lay-verify="NotBlank" msg="{{ Lang.validate_gender_not_chose || "请选择您的称呼" }}">
                                <option value="">{{ Lang.form_select_invite_type || "请选择" }}</option>
                                {% for item in Lang.select.member.register.gender %}
                                    <option value="{{ item.value }}">{{ item.label }}</option>
                                {% endfor %}
                            </select>
                        </div>
                    </div>
                </div>
            </div>

            <div class="layui-row">
                <div class="layui-col-md5 layui-col-xs12">
                    <div class="layui-form-item">
                        <label class="layui-form-label"><i>*</i>{{ Lang.form_text_family_name || "姓" }}:</label>
                        <div class="layui-input-block">
                            <input type="text" name="family_name" lay-verify="family_name" placeholder="" autocomplete="off" class="layui-input" >
                        </div>
                    </div>


                    <div class="layui-form-item">
                        <label class="layui-form-label"><i>*</i>{{ Lang.form_text_given_name || "名" }}:</label>
                        <div class="layui-input-block">
                            <input type="text" name="given_name" lay-verify="given_name" placeholder="" autocomplete="off" class="layui-input" >
                        </div>
                    </div>

                    <div class="layui-form-item">
                        <label class="layui-form-label"><i>*</i>{{ Lang.form_text_email || "电子邮箱" }}:</label>
                        <div class="layui-input-block">
                            <input type="text" name="email" lay-verify="email" autocomplete="off" class="layui-input">
                        </div>
                    </div>

                </div>
            </div>

            {#<div class="layui-row">
                <div class="layui-col-md5 layui-col-xs12">
                    <div class="layui-form-item">
                        <label class="layui-form-label"><i>*</i>{{ Lang.form_text_email || "电子邮箱" }}:</label>
                        <div class="layui-input-inline">
                            <input type="text" name="email" lay-verify="email" autocomplete="off" class="layui-input">
                        </div>
                      <div class="layui-form-mid layui-word-aux">
                            <input type="button" class="layui-btn layui-btn-sm" value="{{  Lang.btn_getCode || "获取验证码" }}" onclick="getCode()" id="J_getCode" />
                            <button class="layui-btn layui-btn-sm layui-btn-primary" id="J_resetCode" style="display:none;" onclick="return false"><span id="J_second">60</span>{{ Lang.form_text_retry_seconds || "秒后重发 " }}</button>
                        </div>
                    </div>
                </div>
               <div class="layui-col-md5 layui-col-xs12 layui-col-md-offset2 layui-col-xs-offset0">

                    <div class="layui-form-item ">
                        <label class="layui-form-label"><i>*</i>{{ Lang.form_placeholder_login_code || "验证码" }}:</label>
                        <div class="layui-input-block">
                            <input type="text" name="verify_code" lay-verify="NotBlank" msg="{{ Lang.validate_captcha_not_null || "请输入验证码" }}" autocomplete="off" class="layui-input">
                        </div>
                    </div>
                </div>
            </div>#}

            <p class="reg-title-2 mt30">{{ Lang.form_text_invite_info || "邀请信息" }}<span>{{ Lang.form_text_invite_ }}</span></p>
            <div class="layui-form-item">
                <label class="layui-form-label">{{ Lang.form_label_invite_code || "邀请码" }}:</label>
                <div class="layui-input-inline">
                    <input type="text" name="invite_code"  lay-verify="invite_code" value="{{ no }}" autocomplete="off" class="layui-input" >
                </div>
            </div>
            <div class="layui-form-item submit-item">
                <div class="layui-input-block">
                    <input type="hidden" name="channel" value="1" autocomplete="off" class="layui-input">
                    <input type="hidden" name="register_ip" value="127.0.0.1" autocomplete="off" class="layui-input" />
                    <span id="keleyivisitorip" style="display: none"></span>
                    <button class="layui-btn" lay-submit lay-filter="live1_next" onclick="return false;">{{ Lang.btn_next || "下一步" }}</button>
                </div>
            </div>
        </form>

    </div>
</div>


{% block js_assets %}
    <script>
        $(function () {
           var invite_code= $("input[name='invite_code']")
          if(invite_code.val() != ""){
              invite_code.attr("readonly","true")
          }
        })
        var account_type = new Object();
        {% for item in Lang.select.member.register.account_type %}
        account_type[{{ item.value }}] = "{{ item.label }}";
        {% endfor %}
        var current_account_type;
        layui.use('form', function(){
            var form = layui.form;
            // 自定义校验规则
            form.verify({
                family_name : function(value){
                    var nameReg=/^[a-zA-Z\u4e00-\u9fa5]{1,20}$/
                    if(!nameReg.test(value)){
                        return '{{ Lang.validate_family_name_format_error || "姓的长度1-20位的字母或汉字" }}';
                    }
                },
                given_name : function(value){
                    var nameReg=/^[a-zA-Z\u4e00-\u9fa5]{1,20}$/
                    if(!nameReg.test(value)){
                        return '{{ Lang.validate_given_name_format_error || "名的长度1-20位的字母或汉字" }}';
                    }
                },
                email : function(value){
                    if(!emailReg.test(value)){
                        return value.trim().length == 0 ? '{{ Lang.msg_email_not_null || "请输入电子邮箱" }}' : '{{ Lang.alert_email_format_error || "邮箱格式不正确" }}';
                    }
                },
                invite_code : function (value) {

                },
                NotBlank: function(value, item){ //value：表单的值、item：表单的DOM对象
                    if(!value){
                        return $(item).attr("msg");
                    }
                }
            });
            var initUploadLeMa = false
            //监听提交
            form.on('submit(live1_next)', function(data){
                // form.render();//全部更新
                var iip = $('#keleyivisitorip')[0].innerHTML;
                data.field.register_ip = iip;
                loading()
                $.ajax({
                    url: '/member/reg/step1',
                    async: true,
                    data: data.field,
                    type:'POST',
                    dataType: "json",
                    contentType: "application/x-www-form-urlencoded;charset=UTF-8",
                    success:function(data){
                        closeLoading()
                        if (data.status == 200) {
                            if(initUploadLeMa == false){
                                initUploadLeMa = true;
                                initUpload();
                            }else{
                                resetUpload()
                            }

                            $('div#live1').attr('style','display: none;');
                            $('div#live2').attr('style','display: block;');
                            var obj = JSON.parse(data.datas);
                            $('#user_id_2').val(obj.id);
                            $('#user_id_3').val(obj.id);

                            var account_type_options = '';
                            var itemLength = obj.items.length;
                            if(itemLength > 1){
                                account_type_options = '<option value=""></option>';
                            }else if(itemLength == 1){
                                current_account_type = obj.items[0];
                            }
                            for(var i = 0; i < itemLength; i++){
                                if(current_account_type == obj.items[i] ){
                                    account_type_options += '<option value="' + obj.items[i] + '" selected>' + account_type[obj.items[i]] + '</option>';
                                }else{
                                    account_type_options += '<option value="' + obj.items[i] + '">' + account_type[obj.items[i]] + '</option>';
                                }
                            }
                            $('select[name="account_type"]').html(account_type_options);
                            form.render('select'); //这个很重要

                            //初始化之前下一步的操作
                            $("#img_upload").hide();
                            $("#img_upload").attr("src", "");
                            $("#card_path").val("");
                            $("#img_upload2").hide();
                            $("#img_upload2").attr("src", "");
                            $("#card_path2").val("");
                        }else{
                            // layer.msg(data.msg, {icon: 5});
                            layer.msg(data.msg, {
                                icon: 5,
                                time: 2000 //2秒关闭（如果不配置，默认是3秒）
                            });
                        }
                    },
                    error : function(jqXHR, textStatus, errorThrown){}
                });
                $("html,body").animate({
                    scrollTop: 0
                }, 400); //点击go to top按钮时，以400的速度回到顶部，这里的400可以根据你的需求修改
                // return false;
                return false; //阻止表单跳转。如果需要表单跳转，去掉这段即可。
            });
        });

        //验证电子邮箱
        function checkEmail(email, cb){
            $.ajax({
                url : 'reg/email_unique',
                async: true,
                data:{'email':email},
                type:'GET',
                dataType: "json",
                contentType:'application/json;charset=utf-8',
                success:function(data){
                    if (data.status == 200){
                        cb(true);
                    }else{
                        cb(false);
                    }
                },
                error : function(jqXHR, textStatus, errorThrown){
                    cb(false);
                }
            });
        }

        /*获取验证码*/
        function getCode(){
            var email = $('input[name="email"]').val();
            if(email == '') {
                layer.msg('{{ Lang.msg_email_not_null || "请输入电子邮箱" }}', {icon: 5, time: 2000});
                return false;
            }
            if(!emailReg.test(email)){
                layer.msg('{{ Lang.alert_email_format_error || "邮箱格式不正确" }}', {icon: 5, time: 2000});
                return false;
            }
            layer.load(2); //上传loading
            //验证电子邮箱
            checkEmail(email, function (flag) {
                layer.closeAll('loading'); //关闭loading
                if(!flag){
                    layer.msg("{{ Lang.msg_email_already_existed || "电子邮箱已存在" }}", {icon: 5, time: 2000});
                    return false;
                }
               /* $.ajax({
                    url :'reg/verify_code',
                    async: true,
                    data:{'email':email},
                    type:'GET',
                    dataType: "json",
                    contentType:'application/json;charset=utf-8',
                    success:function(data){
                        if (data.status == 200) {

                            resetCode(); //倒计时
                            layer.msg('{{ Lang.msg_verify_code_send_success || "验证码已发送，请及时查收！" }}', {icon: 1, time: 2000});
                        }else{
                            layer.msg(data.msg, {icon: 5, time: 2000});
                        }
                    },
                    error : function(jqXHR, textStatus, errorThrown){}
                });*/
            });
        }
        //倒计时
        function resetCode(){
            $('#J_getCode').hide();
            $('#J_second').html('60');
            $('#J_resetCode').show();
            $('#J_resetCode').addClass('layui-btn layui-btn-disabled');
            var second = 60;
            var timer = null;
            timer = setInterval(function(){
                second -= 1;
                if(second >0 ){
                    $('#J_second').html(second);
                }else{
                    clearInterval(timer);
                    $('#J_getCode').show();
                    $('#J_resetCode').hide();
                }
            },1000);
        }

    </script>
{% endblock %}