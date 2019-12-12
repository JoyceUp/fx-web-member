{% extends '../../common/layouts/layout.tpl' %}

{% block css_assets %}
    {# 引入css #}

{% endblock %}


{% block js_assets %}
    {# 引入js #}
    <script type="text/javascript" src="/assets/vendors/mathUtil.js"></script>
    <script>

        $(function () {
            formatVar()
        })
        var deposit_min_limit ={{ system_setting.deposit_min_limit / 100 }}
        formatVar = function(){
            $("p").each(function(){
               var  html =$(this).html()
                html =  html.replace('[deposit_min_limit]',deposit_min_limit);
                html =  html.replace('[deposit_min_limit]',deposit_min_limit);
                html =  html.replace('[deposit_min_limit]',deposit_min_limit);
               $(this).html(html)

                if(html.indexOf("--")>-1){

                  var htmlArr = html.split("--")
                    var newHtml = htmlArr[0]+"<a href='javascript:;' onclick='showCompTTInfo()'>"+htmlArr[1]+"</a>"+htmlArr[2]
                    $(this).html(newHtml)
                }
            })

        }
        var deposit_min_limit = {{ system_setting.deposit_min_limit / 100 }} || 0;
        var deposit_max_limit ={{ system_setting.deposit_max_limit / 100 }}|| 0

        layui.use('upload', function () {
            var $ = layui.jquery
                , upload = layui.upload;

            var img_base64;
            //普通图片上传
            var uploadInst = upload.render({
                elem: '#upload'
                , url: '/common/upload/'
                ,data: {role_type: window.user.role_type, role_id: window.user.user_id}
                 //限制文件大小，单位 KB
                , exts: 'png|jpg|jpeg' //只允许上传png|jpg
                , before: function (obj) {
                    //预读本地文件示例，不支持ie8
                    layer.load(2); //上传loading
                    obj.preview(function (index, file, result) {
                        img_base64 = result;
                    });

                }

                , done: function (res) {

                    layer.closeAll('loading'); //关闭loading
                    //如果上传失败
                    if (res.code > 0) {
                        return layer.msg('{{ Lang.msg_upload_error || "上传失败" }}');
                    }
                    $("#img_id").val(JSON.parse(res.datas).id);
                    //上传成功
                    $('#upload_img').attr('src', img_base64); //图片链接（base64）
                }
                , error: function () {
                    layer.closeAll('loading'); //关闭loading
                    //演示失败状态，并实现重传
                    var demoText = $('#demoText');
                    demoText.html('<span style="color: #FF5722;">{{ Lang.msg_upload_error || "上传失败" }}</span> <a class="layui-btn layui-btn-mini demo-reload">{{ Lang.msg_retry || "重试" }}</a>');
                    demoText.find('.demo-reload').on('click', function () {
                        uploadInst.upload();
                    });
                }
            });
        });
        var deposit_type = 1
        layui.use(['form','element'], function(){
            var form = layui.form;
            var layer = layui.layer;
            var element = layui.element;
            element.on('tab(deposit_tab)', function(){
                deposit_type = this.getAttribute('lay-id')
            });
            form.verify({
                balance: function(value, item){ //value：表单的值、item：表单的DOM对象
                    if(!value){
                        return '{{ Lang.validate_amount_not_null || "请填写申请金额" }}';
                    }
                    if(!/^[0-9.]*$/.test(value)){
                        return '{{ Lang.validate_deopsit_amount_only_number || "入金金额必须为数字" }}';
                    }

                    if(value < deposit_min_limit){
                        return '{{ Lang.validate_deopsit_amount_minimum || "入金最少额度为" }}' + deposit_min_limit + '{{ Lang.validate_amount_dollar || "美元" }}';
                    }

                    if(deposit_type ==1 ){
//                       var rmb = accDiv(accMul(value, rate), 10000)
                       var rmb = $("#bank_pay_amount").val()



                        if(rmb> deposit_max_limit){
                            return '{{ Lang.validate_deopsit_amount_max || "银行卡入金最大额度为" }}' + deposit_max_limit + '{{ Lang.validate_amount_rmb || "人民币" }}';
                        }
                    }

                },
                NotBlank: function(value, item){ //value：表单的值、item：表单的DOM对象
                    if(!value){
                        return $(item).attr("msg");
                    }
                }
            });

            //监听提交 银行卡
            form.on('submit(sub_btn_1)', function (data) {
                data.field.type = 1;
                data.field.msg = "{{ Lang.page_member_withdraw_bankcard_msg_txt || "您的入金信息如下所示，请确认信息无误后，点击“确定”按钮，跳转至网上银行。" }}";
                showConfirm(data.field);
                return false;
            });

            //监听提交 电汇
            form.on('submit(sub_btn_2)', function (data) {
                data.field.type = 2;
                data.field.msg = "{{ Lang.page_member_withdraw_dh_msg_txt || "您的入金信息如下所示，请确认信息无误后，点击“确定”按钮。" }}";
                showConfirm(data.field);
                return false;
            });

            //监听提交 微信
            form.on('submit(sub_btn_3)', function (data) {
                data.field.type = 3;
                data.field.msg = "{{ Lang.page_member_withdraw_wx_msg_txt || "您的入金信息如下所示，请确认信息无误后，点击“确定”按钮，跳转至微信支付界面。。" }}";
                showConfirm(data.field);
                return false;
            });

            //监听确认
            form.on('submit(confirm)', function (data) {
                layer.closeAll();
                if(data.field.type == 1){
                    $("#bank_form").submit();

                    // $("#bank_form_reset_button").click();
                    layer.confirm('{{ Lang.open_deposit_guide || "请您在新打开的页面上完成入金，入金完成后，根据实际支付情况选择点击下面的按钮。" }}', {
                        btn: ['{{ Lang.btn_gold_to_success || "入金成功" }}', '{{ Lang.btn_gold_to_fail || "入金失败" }}'] //按钮
                        ,closeBtn: 0    // 是否显示关闭按钮
                    }, function () {
                        window.location = "/member/funds/deposit"
                    }, function () {
                        layer.closeAll();
                    });
                }else if(data.field.type == 2){
                    submit(data.field);
                }else if(data.field.type == 3){
                    $("#wechat_form").submit();
                    // $("#wechat_form_reset_button").click();
                    layer.confirm('{{ Lang.open_deposit_guide || "请您在新打开的页面上完成入金，入金完成后，根据实际支付情况选择点击下面的按钮。" }}', {
                        btn: ['{{ Lang.btn_gold_to_success || "入金成功" }}', '{{ Lang.btn_gold_to_fail || "入金失败" }}'] //按钮
                        ,closeBtn: 0    // 是否显示关闭按钮
                    }, function () {
                        window.location = "/member/funds/deposit"
                    }, function () {
                        layer.closeAll();
                    });
                }
                return false;
            });
        });
        function showConfirm(data) {

            $("#confirm #msg").html(data.msg);
            $("#type").val(data.type);

            var account = data.account.split(",");

            $("#account_no_confirm_show").html(account[1]);
            if(data.type == 1) {
                $("#bank_account_id_hidden").val(account[0]);
            }else if(data.type == 2){
                $("#account_id_confirm_hidden").val(account[0]);
            }else if(data.type == 3){
                $("#wechat_account_id_hidden").val(account[0]);
            }

            if(data.type ==1){
          
                //汇率
                $("#rate_confirm_show").html(data.rate / 10000);
                $("#rate_confirm_hidden").val(data.rate);
                $("#rate_confirm_show_div").show();
                //申请金额

                $("#amount_confirm_show").html(data.amount / 100);
                $("#amount_confirm_hidden").val(data.amount);
                //支付金额
                $("#pay_amount_confirm_show").html(data.pay_amount/100);
                $("#pay_amount_confirm_hidden").val(data.pay_amount);
                $("#pay_amount_confirm_show_div").show();
            }else if(data.type ==3){

                if(data.pay_amount > 330000){
                    layer.msg("微信入金最大金额为3300人民币", {icon: 2})
                    return
                }
                //汇率
                $("#rate_confirm_show").html(data.rate / 10000);
                $("#rate_confirm_hidden").val(data.rate);
                $("#rate_confirm_show_div").show();
                //申请金额

                $("#amount_confirm_show").html(data.amount / 100);

                //支付金额
                $("#pay_amount_confirm_show").html(data.pay_amount/ 100);

                $("#pay_amount_confirm_show_div").show();
            }else{
                $("#tt_path_confirm_hidden").val(data.tt_path);

                $("#amount_confirm_show").html(data.amount);
                $("#amount_confirm_hidden").val(data.amount);
                $("#rate_confirm_show_div").hide();
                $("#pay_amount_confirm_show_div").hide();
            }

            layer.open({
                type:1,
                title:'{{ validate_entry_order }}',
                area:['500px', 'auto'],
                content:$('#confirm')
            });
        }
        function closeConfirm() {
            layer.closeAll();
        }
        var submit_f = false;
        function submit(data) {
            if(submit_f){
                return false;
            }
            submit_f = true;
            $.ajax({
                url: "/member/transaction/deposit/submit_deposit",
                async: true,
                data: data,
                type: "post",
                dataType: "json",
                contentType: "application/x-www-form-urlencoded;charset=utf-8",
                success: function (data) {
                    submit_f = false;
                    if (data.status == 200) {
                        layer.alert("{{ Lang.alert_deposit_submit_success || "我们已收到您的电汇入金申请，工作人员会在确认收到款项之后为您办理入金，请耐心等待。" }}", {
                            title: '{{ Lang.page_text_submit_success || "提交完成" }}'
                            ,closeBtn: 0    //是否显示关闭按钮,0隐藏 1显示
                        }, function(index){
                            $("#tt_form_reset_button").click();

                            //清空汇票
                            $("#img_id").val("");
                            $('#upload_img').attr('src', "");
                            layer.closeAll();
                        });
                    }else{
                        layer.alert(data.msg, {
                            title: '{{ Lang.page_msg_h3 || "提示：" }}'
                        });
                    }
                },
                error: function (jqXHR, textStatus, errorThrown) {
                }
            });
        }

        //计算支付金额
        var rate = {{ rate  }};
            rate = accMul(rate,10000);
            $("input[name=rate]").val(rate);
        function usd2rmb(e, id) {
            if (e.value.length > 12) {
                e.value = e.value.slice(0, 12);
            }
            keepMoneyFloat(e);

            var v = 0;
            var value = 0;
            if($(e).val()){
                value = $(e).val()
                v = toFixed(accDiv(accMul(value, rate), 10000), 2);
            }
            //实际支付的钱
            if(!v){
                v = 0;
            }
            $("#"+ id + "_hidden_input").val(accMul(value, 100));      //传给第三方支付的数额
            //计算显示的钱
            $("#" + id).val(v);
        }

        function rmb2usd(e, id) {
            if(e.value.length > 12){
                e.value = e.value.slice(0, 12);
            }
            e.value = e.value.replace(/[^0-9-]+/,"");

            var v = 0;
            var value = 0;
            if($(e).val()){
                value = $(e).val()
                v = toFixed(accMul(accDiv(value, rate), 10000), 2);
            }
            //实际支付的钱
            if(!v){
                v = 0;
            }

//            $("#"+ id + "_hidden_input").val(accMul(v, 100));      //传给第三方支付的数额
            $("#bank_amount_hidden_input").val(accMul(v, 100));      //传给第三方支付的数额
            $("#bank_pay_amount_hidden_input").val(accMul(value, 100));      //传给第三方支付的数额
            $("#"+ id + "_usd").val(v);

            //计算显示的钱
            /*$("#" + id + "_show").html(v);*/
         //   $("#" + id).val(v);
        }


        function usd2rmb(e, id) {
            if (e.value.length > 12) {
                e.value = e.value.slice(0, 12);
            }
            keepMoneyFloat(e);

            var v = 0;
            var value = 0;
            if($(e).val()){
                value = $(e).val()
                v = toFixed(accDiv(accMul(value, rate), 10000), 2);
            }
            //实际支付的钱
            if(!v){
                v = 0;
            }
            $("#"+ id + "_hidden_input").val(accMul(value, 100));      //传给第三方支付的数额
            //计算显示的钱
            $("#" + id).val(v);
        }

        function rmb2usdWecha(e, id) {
            if(e.value.length > 12){
                e.value = e.value.slice(0, 12);
            }
            e.value = e.value.replace(/[^0-9-]+/,"");

            var v = 0;
            var value = 0;
            if($(e).val()){
                value = $(e).val()
                v = toFixed(accMul(accDiv(value, rate), 10000), 2);
            }
            //实际支付的钱
            if(!v){
                v = 0;
            }

            $("#we_amount_hidden_input").val(accMul(v, 100));      //传给第三方支付的数额
            $("#we_pay_amount_hidden_input").val(accMul(value, 100));      //传给第三方支付的数额

            $("#"+ id + "_usd").val(v);

            //计算显示的钱
            /*$("#" + id + "_show").html(v);*/
            //   $("#" + id).val(v);
        }

        function keepMoney(obj) {

            var A = $(obj);
            var value = A.val();
            if (value == "-" || value == "") {
                A.attr("lastValue", "");
                A.val("");
                return true;
            }
            var reg = new RegExp(/^\d{1,12}($)/);
            var lastValue = A.attr("lastValue") || "";
            var flag = reg.test(value);
            if (flag) {
                lastValue = value;
                A.attr("lastValue", lastValue);
                return lastValue;
            } else {
                A.val(lastValue);
                return lastValue;
            }
        }
        function keepMoneyFloat(obj) {

            var A = $(obj);
            var value = A.val();
            if (value == "-" || value == "") {
                A.attr("lastValue", "");
                A.val("");
                return true;
            }
            var reg = new RegExp(/^\d{1,12}(\.\d{0,2}$|$)/);
            var lastValue = A.attr("lastValue") || "";
            var flag = reg.test(value);
            if (flag) {
                lastValue = value;
                A.attr("lastValue", lastValue);
                return lastValue;
            } else {
                A.val(lastValue);
                return lastValue;
            }
        }

        //显示公司电汇信息
        function showCompTTInfo() {
            layer.open({
                type: 1,
                title: "{{ Lang.page_customer_deposit_title || "电汇收款信息" }}",
                area: ['540px', 'auto'], //宽高
                content: $("#tt_detail")
            });
        }
    </script>
{% endblock %}

{% block content %}
    <div class="main_content">
        <div class="main_content_holder">
            <div id="fund">
                <div class="main_head">
                    <div class="main_head_unit">
                        {{ Lang.page_transaction_deposit_title || "账户入金" }}
                    </div>
                    <div class="main_head_text required"></div>
                </div>
                <div class="main_page_Info">
                    <div class="form">
                        <div class="form_input">

                            <div class="layui-tab" lay-filter="deposit_tab">
                                <ul class="layui-tab-title">
                                    <li class="layui-this" lay-id="1">{{ Lang.form_text_bank_deposit || "银行卡入金" }}</li>
                                    <li  lay-id="2">{{ Lang.form_text_transfer_gold || "电汇入金" }}</li>
                                    {#<li lay-id="3">{{ Lang.form_text_WeChat_fund || "微信入金" }}</li>#}
                                </ul>
                                <div class="layui-tab-content">
                                    <div class="layui-tab-item layui-show">
                                        <div class="from_alert">
                                            <h3>{{ Lang.page_transaction_deposit_yhk_msg_h3 || "银行卡入金操作说明：" }}</h3>
                                            <p>{{ Lang.page_transaction_deposit_yhk_msg_txt1 || "1.入金金额： 每次入金金额不得低于美金，系统将会自动将美金转换成人民币。" }}</p>
                                            <p>{{ Lang.page_transaction_deposit_yhk_msg_txt2 || "2.可接受货币: 人民币（请确认仅使用本人的银行卡入金，第三方入金将无法取款）。" }}</p>
                                            <p>{{ Lang.page_transaction_deposit_yhk_msg_txt3 || "3.到账时间 (大约）: 即时到账（备注：可能因系统问题造成入金延迟，补仓敬请提前入金）。" }}</p>
                                        </div>
                                        <form class="layui-form form" id="bank_form" action="{{ payUrl }}bankcard" method="post" target="_blank">
                                        <form class="layui-form form" id="bank_form" action="http://www.xinanchuangying.com/mdffx-payserv/api/v1/customer/deposit/bankcard" method="post" target="_blank">
                                            <div class="layui-form-item">
                                                <label class="layui-form-label"><i>*</i>{{ Lang.form_placeholder_account_no || "账号" }}：</label>
                                                <div class="layui-input-block">
                                                    <select name="account" lay-filter="account" lay-verify="NotBlank" msg="{{ Lang.validate_account_not_chose || "请选择账号" }}">
                                                        <option value="">{{ Lang.form_select_invite_type || "请选择" }}</option>
                                                        {% for ac in account %}
                                                            {% if ac.state != 51 %}
                                                                <option value="{{ ac.id }},{{ ac.account_no }}-{{ ac.account_type | accountType }}">{{ ac.account_no }}-{{ ac.account_type | accountType }}</option>
                                                            {% endif %}
                                                        {% endfor %}
                                                    </select>
                                                    <input type="hidden" id="bank_account_id_hidden" name="account_id"/>
                                                </div>
                                            </div>
                                            <div class="layui-form-item">
                                                <label class="layui-form-label">{{ Lang.form_label_rate || "汇率" }}：</label>
                                                <div class="layui-form-mid layui-word-aux" id="rate">{{ rate }}</div>
                                                <input type="hidden" name="rate" value="{{ rate * 10000 }}"/>
                                            </div>


                                            <div class="layui-form-item">
                                                <label class="layui-form-label"><i>*</i>{{ Lang.form_label_application_amount_cny || "申请金额(CNY)" }}：</label>

                                                <div class="layui-input-block">
                                                <input type="text"  id="bank_pay_amount" lay-verify="NotBlank|number" msg="{{ Lang.validate_amount_not_null || "请填写申请金额" }}" autocomplete="off" class="layui-input" oninput="rmb2usd(this, 'bank_pay_amount')"/>
                                                    <input type="hidden" name="pay_amount" id="bank_pay_amount_hidden_input"/>
                                                </div>
                                            </div>

                                            <div class="layui-form-item">
                                                <label class="layui-form-label"><i>*</i>{{ Lang.form_label_application_amount || "申请金额(USD)" }}：</label>
                                                <div class="layui-input-block">
                                                    <input type="text" id="bank_pay_amount_usd" style="border:none" disabled lay-verify="balance" class="layui-input" oninput="usd2rmb(this, 'bank_pay_amount')"/>
                                                    <input type="hidden" name="amount" id="bank_amount_hidden_input"/>
                                                </div>
                                            </div>

                                            <div class="layui-form-item">
                                                <div class="layui-input-block">
                                                    <button class="layui-btn" lay-submit="" lay-filter="sub_btn_1" onclick="javascript:return false;">{{ Lang.btn_sub || "提交"  }}</button>
                                                    <button type="reset" style="display: none;" id="bank_form_reset_button" class="layui-btn layui-btn-primary">{{ Lang.btn_reset || "清空" }}</button>
                                                </div>
                                            </div>
                                        </form>

                                    </div>
                                    <div class="layui-tab-item ">
                                        <div class="from_alert">

                                            <h3>{{ Lang.page_transaction_deposit_dh_msg_h3 || "电汇入金操作说明：" }}</h3>
                                            <p>{{ Lang.page_transaction_deposit_dh_msg_txt1 || "每次最低入金金额不得低于[deposit_min_limit]美金" }}</p>
                                            <p>{{ Lang.page_transaction_deposit_dh_msg_txt2 || "请电汇至 <a onclick='showCompTTInfo()'>公司电汇账户</a> 后，将汇票凭证上传至页面" }}</p>
                                            <p>{{ Lang.page_transaction_deposit_dh_msg_txt3 || "3. 电汇入金，平台不收取任何费用，但银行可能产生一定的服务费用。" }}</p>

                                        </div>

                                        <form class="layui-form form" action="">

                                            <div class="layui-form-item">
                                                <label class="layui-form-label"><i>*</i>{{ Lang.form_placeholder_account_no || "账号" }}：</label>
                                                <div class="layui-input-block">
                                                    <select name="account" lay-filter="account" lay-verify="NotBlank" msg="{{ Lang.validate_account_not_chose || "请选择账号" }}">
                                                        <option value="">{{ Lang.form_select_invite_type || "请选择" }}</option>
                                                        {% for ac in account %}
                                                            {% if ac.state != 51 %}
                                                                <option value="{{ ac.id }},{{ ac.account_no }}-{{ ac.account_type | accountType }}">{{ ac.account_no }}-{{ ac.account_type | accountType }}</option>
                                                            {% endif %}
                                                        {% endfor %}
                                                    </select>
                                                </div>
                                            </div>

                                            <div class="layui-form-item">
                                                <label class="layui-form-label"><i>*</i>{{ Lang.form_label_application_amount || "申请金额(USD)" }}：</label>
                                                <div class="layui-input-block">
                                                    <input type="text" name="amount" lay-verify="balance" oninput="keepMoney(this)" class="layui-input"/>
                                                </div>
                                            </div>

                                            <div class="layui-form-item">
                                                <label class="layui-form-label"><i>*</i>{{ Lang.form_label_proof_photo || "汇票凭证" }}：</label>
                                                <div class="layui-input-block">
                                                    <div class="layui-upload">
                                                        <button type="button" class="layui-btn" id="upload" onclick="return false;">{{ Lang.btn_upload || "上传" }}</button>
                                                        <div class="layui-upload-list">
                                                            <img class="layui-upload-img" id="upload_img">
                                                            <input type="hidden" name="tt_path" id="img_id" value="" lay-verify="NotBlank" msg="{{ Lang.validate_tt_path_not_null || "请上传汇票凭证" }}"/>
                                                            <p id="demoText"></p>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="layui-form-item">
                                                <div class="layui-input-block">
                                                    <button class="layui-btn" lay-submit="" lay-filter="sub_btn_2" onclick="javascript:return false;">{{ Lang.btn_sub || "提交" || "提交" }}</button>
                                                    <button type="reset" style="display: none;" id="tt_form_reset_button" class="layui-btn layui-btn-primary">{{ Lang.btn_reset || "清空" }}</button>
                                                </div>
                                            </div>
                                        </form>

                                    </div>
                                    <div class="layui-tab-item">

                                        <div class="from_alert">
                                            <h3>{{ Lang.page_transaction_deposit_wx_msg_h3 || "微信入金操作说明：" }}</h3>
                                            <p>{{ Lang.page_transaction_deposit_wx_msg_txt1_1 || "1. 每次入金金额不得低" }}</p>
                                            <p>{{ Lang.page_transaction_deposit_wx_msg_txt2 || "2. 微信入金无手续费，金额将会即时汇入您的MT4账户。" }}</p>
                                        </div>

                                        <form class="layui-form form" id="wechat_form" action="{{ payUrl }}wechat" method="post" target="_blank">
                                        {#<form class="layui-form form" id="wechat_form" action="http://www.xinanchuangying.com/mdffx-payserv/api/v1/customer/deposit/wechat" method="post" target="_blank">#}

                                            <div class="layui-form-item">
                                                <label class="layui-form-label"><i>*</i>{{ Lang.form_placeholder_account_no || "账号" }}：</label>
                                                <div class="layui-input-block">
                                                    <select name="account" lay-filter="account" lay-verify="NotBlank" msg="{{ Lang.validate_account_not_chose || "请选择账号" }}">
                                                        <option value="">{{ Lang.form_select_invite_type || "请选择" }}</option>
                                                        {% for ac in account %}
                                                            {% if ac.state != 51 %}
                                                                <option value="{{ ac.id }},{{ ac.account_no }}-{{ ac.account_type | accountType }}">{{ ac.account_no }}-{{ ac.account_type | accountType }}</option>
                                                            {% endif %}
                                                        {% endfor %}
                                                    </select>
                                                    <input type="hidden" id="wechat_account_id_hidden" name="account_id"/>
                                                </div>
                                            </div>
                                            <div class="layui-form-item">
                                                <label class="layui-form-label">{{ Lang.form_label_rate || "汇率" }}：</label>
                                                <div class="layui-form-mid layui-word-aux" id="rate">{{ rate }}</div>
                                                <input type="hidden" name="rate" value="{{ rate * 10000 }}"/>
                                            </div>

                                            <div class="layui-form-item">
                                                <label class="layui-form-label"><i>*</i>{{ Lang.form_label_application_amount_cny || "申请金额(CNY)" }}：</label>

                                                <div class="layui-input-block">
                                                    <input type="text" name="pay_amount_input" id="we_pay_amount" lay-verify="NotBlank|number" msg="{{ Lang.validate_amount_not_null || "请填写申请金额" }}" autocomplete="off" class="layui-input" oninput="rmb2usdWecha(this, 'we_pay_amount')" />
                                                    <input type="hidden" name="pay_amount" id="we_pay_amount_hidden_input"/>
                                                </div>
                                            </div>


                                            <div class="layui-form-item">
                                                <label class="layui-form-label"><i>*</i>{{ Lang.form_label_application_amount || "申请金额(USD)" }}：</label>
                                                {#<div class="layui-form-mid" id="we_pay_amount_usd"></div>#}
                                                <div class="layui-input-block">

                                                   <input type="text" style="border:none" id="we_pay_amount_usd" lay-verify="balance" class="layui-input"  disabled/>
                                                    <input type="hidden" name="amount" id="we_amount_hidden_input"/>
                                                </div>
                                            </div>


                               {#             <div class="layui-form-item form">
                                                <label class="layui-form-label"><i>*</i>{{ Lang.form_label_application_amount || "申请金额(USD)" }}：</label>
                                                <div class="layui-input-block">
                                                    <input type="text" lay-verify="balance" class="layui-input" onkeydown="usd2rmb(this, 'we_pay_amount')" onkeyup="usd2rmb(this, 'we_pay_amount')"/>
                                                    <input type="hidden" name="amount" id="we_pay_amount_hidden_input"/>
                                                </div>
                                            </div>

                                            <div class="layui-form-item">
                                                <label class="layui-form-label">{{ Lang.form_label_pay_amount || "支付金额(CNY)" }}：</label>
                                                <div class="layui-form-mid layui-word-aux" id="we_pay_amount_show">0.00</div>
                                                <input type="hidden" name="pay_amount" id="we_pay_amount" lay-verify="required|number" autocomplete="off" class="layui-input">
                                            </div>#}

                                            <div class="layui-form-item">
                                                <div class="layui-input-block">
                                                    <button class="layui-btn" lay-submit="" lay-filter="sub_btn_3" onclick="javascript:return false;">{{ Lang.btn_sub || "提交" || "提交" }}</button>
                                                    <button type="reset" style="display: none;" id="wechat_form_reset_button" class="layui-btn layui-btn-primary">{{ Lang.btn_reset || "清空" }}</button>
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
        </div>
    </div>

    <div id="tt_detail" style="display:none;">
        <form class="layui-form show-detail" action="">
            <div class="d-item">
                <label>{{ Lang.form_text_beneficiary_account || " 收款人账号 " }}:</label>
                <span >1010862333 (USD)</span>
            </div>
            <div class="d-item">
                <label>{{ Lang.form_text_beneficiary_name || " 收款人名称 " }}:</label>
                <span >PT. REAL TIME FUTURES</span>
            </div>
            <div class="d-item">
                <label>{{ Lang.form_text_beneficiary_address || " 收款人地址 " }}:</label>
                <span > International Financial Center 2, lt 19.JL. Jendral Sudirman Kav. 22-23, RT.10/RW.1, Karet, Kota Jakarta Selatan, Daerah Khusus Ibukota Jakarta 12920,

                </span>
            </div>
            <div class="d-item">
                <label>{{ Lang.form_text_beneficiary_branch_name || " 收款人开户银行名称 " }}:</label>
                <span >PT. BANK CHINA CONSTRUCTION BANK INDONESIA,TBK(CCB)</span>
            </div>
            <div class="d-item">
                <label>{{ Lang.form_text_beneficiary_branch_address || " 收款人开户银行地址 " }}:</label>
                <span >KK. RAWAMANGUN<br/>Jl. Pemuda No. 33 A Rawamangun<br/>Jakarta Timur 13220
                </span>
            </div>
            <div class="d-item">
                <label>SWIFT CODE:</label>
                <span > BWKIIDJA</span>
            </div>
            <br/>
            <hr>
            <br/>
            <div class="d-item">
                <label>{{ Lang.form_text_beneficiary_account || " 收款人账号 " }}:</label>
                <span >0353251021 (USD)</span>
            </div>
            <div class="d-item">
                <label>{{ Lang.form_text_beneficiary_name || " 收款人名称 " }}:</label>
                <span >PT. REAL TIME FUTURES</span>
            </div>
            <div class="d-item">
                <label>{{ Lang.form_text_beneficiary_address || " 收款人地址 " }}:</label>
                <span > International Financial Center 2, lt 19.JL. Jendral Sudirman Kav. 22-23, RT.10/RW.1, Karet, Kota Jakarta Selatan, Daerah Khusus Ibukota Jakarta 12920,


                </span>
            </div>
            <div class="d-item">
                <label>{{ Lang.form_text_beneficiary_branch_name || " 收款人开户银行名称 " }}:</label>
                <span >Bank central asia sudirman  (BCA)</span>
            </div>
            <div class="d-item">
                <label>{{ Lang.form_text_beneficiary_branch_address || " 收款人开户银行地址 " }}:</label>
                <span >Gedung Chase Plaza, Jl. Jend. Sudirman Kav. 21<br>
Jakarta Selatan, DKI Jakarta, Indonesia

                </span>
            </div>
            <div class="d-item">
                <label>SWIFT CODE:</label>
                <span > CENAIDJA</span>
            </div>



        </form>

    </div>
    <div id="confirm" style="display:none">
        <div id="msg" style="margin: 20px 30px -16px 30px;"></div>
        <form class="layui-form show-detail" action="">
            <input type="hidden" id="type" name="type">
            <input type="hidden" name="tt_path" id="tt_path_confirm_hidden"/>
            <div class="d-item">
                <label>{{ Lang.form_placeholder_account_no || "账号" }}:</label>
                <span id="account_no_confirm_show"></span>
                <input type="hidden" id="account_id_confirm_hidden" name="account_id"/>
            </div>

            <div class="d-item" id="rate_confirm_show_div" style="display: none">
                <label>{{ Lang.form_label_rate || "汇率" }}:</label>
                <span id="rate_confirm_show"></span>
                <input type="hidden" id="rate_confirm_hidden" name="rate"/>
            </div>

            <div class="d-item" id="pay_amount_confirm_show_div">
                <label>{{ Lang.form_label_application_amount_cny || "申请金额(CNY)" }}:</label>
                <span id="pay_amount_confirm_show"></span>
                <input type="hidden" id="pay_amount_confirm_hidden" name="pay_amount"/>
            </div>

            <div class="d-item">
                <label>{{ Lang.form_label_application_amount || "申请金额(USD)" }}:</label>
                <span id="amount_confirm_show"></span>
                <input type="hidden" id="amount_confirm_hidden" name="amount"/>
            </div>



            <div class="canceApply" id="cancel_btn_div">
                <input lay-submit="" type="button" lay-filter="confirm" class="layui-btn" value="{{ Lang.btn_true || "确定" }}"/>
                <input type="button" onclick="closeConfirm()" class="layui-btn" value="{{ Lang.btn_cancel || "取消" }}"/>
            </div>
        </form>
    </div>
{% endblock %}


