{% extends '../../common/layouts/layout.tpl' %}
{% set sale_setting = Lang.select.sale %}
{% block content %}
    <div class="main_content">
        <div class="main_content_holder">
            <div id="fund">
                <div class="main_head">
                    <div class="main_head_unit">
                        {{ Lang.page_ib_info_title || "代理详情" }}<div style="float:right;margin-bottom:10px"><button class="layui-btn layui-btn-normal" onclick="javascript:history.go(-1)">{{ Lang.btn_back || "返回" }}</button></div>
                    </div>

                    <div id="search_box">
                        <span>{{ Lang.form_text_personal_info || "个人信息" }}</span>
                        <div class="layui-row">
                            <div class="layui-col-md4 layui-col-md-offset2" style="line-height: 25px">
                                <input type="hidden" id="ibId" value="{{ datas.info.id }}"/>
                                <p>{{ Lang.form_placeholder_name || "姓名" }}：{{ datas.info.full_name }}</p>
                                <p>{{ Lang.form_text_email || "电子邮箱" }}：{{ datas.info.email }}</p>
                                <p>{{ Lang.form_text_identity_type || "证件类型" }}：{{ datas.identity.identity_type | identityType }}</p>
                                <p>{{ Lang.form_text_country || "国家" }}：{{ datas.address.country }}</p>
                                <p>{{ Lang.form_text_address || "居住地址" }}：{{ datas.address.address }}</p>
                            </div>
                            <div class="layui-col-md4 layui-col-md-offset1" style="line-height: 25px">
                                <p>{{ Lang.form_text_gender || "称呼" }}：{{ sale_setting.gender[datas.info.gender] }}</p>
                                <p>{{ Lang.form_text_mobile || "手机号码" }}：{{ datas.info.mobile }}</p>
                                <p>{{ Lang.form_text_identity_no || "证件号码" }}：{{ datas.identity.identity_no | hideIdentityNo }}</p>
                                <p>{{ Lang.form_text_city || "城市" }}：{{ datas.address.city }}</p>
                                <p>{{ Lang.form_text_zip_code || "邮政编码" }}：{{ datas.address.zip_code }}</p>
                            </div>

                        </div>
                    </div>
                    <div class="layui-tab layui-tab-card">
                        <ul class="layui-tab-title">
                            <li class="layui-this">{{ Lang.form_text_account_info || "账号信息" }}</li>
                            <li>{{ Lang.form_text_withdraw_info || "出金信息" }}</li>
                            <li>{{ Lang.form_text_transfer_info_two || "转账信息" }}</li>
                            <li>{{ Lang.form_text_rebate_info || "返利信息" }}</li>
                            <li>{{ Lang.form_text_commission_info || "返佣信息" }}</li>
                        </ul>
                        <div class="layui-tab-content" >
                            <div class="layui-tab-item layui-show">

                                <table id="account_table" class="layui-hide"></table>
                                <div class="page"></div>

                            </div>
                            <div class="layui-tab-item ">

                                <table id="deposit_table" class="layui-hide"></table>
                                <div class="page"></div>

                            </div>
                            <div class="layui-tab-item ">

                                <table id="transfer_table" class="layui-hide"></table>
                                <div class="page"></div>

                            </div>
                            <div class="layui-tab-item">

                                <table id="rebate_table" class="layui-hide"></table>
                                <div class="page"></div>

                            </div>
                            <div class="layui-tab-item">

                                <table id="commission_table" class="layui-hide"></table>
                                <div class="page"></div>

                            </div>

                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>>
{% endblock %}

{% block js_assets %}
    <script>

        var orderStateMap = new Object();
        {% for at in Lang.select.sale.order_state %}
            orderStateMap[{{ at.value }}] = "{{ at.label}}";
        {% endfor %}

        var accountStateMap = new Object();
        {% for at in Lang.select.sale.agent_account_state %}
        accountStateMap[{{ at.value }}] = "{{ at.label}}";
        {% endfor %}

        var fundsTypeMap = new Object();
        {% for at in Lang.select.sale.funds_type %}
        fundsTypeMap[{{ at.value }}] = "{{ at.label }}";
        {% endfor %}

        var accountTypeMap = new Object();
        {% for at in Lang.select.sale.account_type %}
        accountTypeMap[{{ at.value}}] = "{{ at.label }}";
        {% endfor %}

        var tableIns_account;
        var tableIns_Money;
        var tableIns_transform;
        var tableIns_rebate;
        var tableIns_commission;

        var ib_id = $("#ibId").val();
        layui.use(['element','table'], function(){
            var $ = layui.jquery
                ,element = layui.element; //Tab的切换功能，切换事件监听等，需要依赖element模块

            var table = layui.table;
            //账号信息
            tableIns_account=table.render({
                elem: '#account_table'
                ,url: '/sale/ib/account/list'//数据接口
                ,page: true //开启分页
                ,where:{
                    ibid:ib_id
                }
                ,method:'post'
                ,cols: [[ //表头
                    {field: 'account_no', title: '{{ Lang.table_source_account_no || "账号"}}', align:'center'},
                    {field: 'account_type', title: '{{ Lang.table_source_account_type || "账户类型"}}', align:'center',templet:function(d){
                        return accountTypeMap[d.account_type];
                        }},
                    {field: 'balance', title: '{{ Lang.table_balance || "账户余额"}}', align:'center',templet:function(d){
                        if(d.balance){
                            return d.balance / 100;
                        }else{
                        return 0;}
                        }}
                    ,{field: 'state', title: '{{ Lang.table_account_state || "账户状态"}}', align:'center',templet:function(d){
                        return accountStateMap[d.state];
                        }},
                    {field: 'gmt_create', title: '{{ Lang.table_gmt_create_1 || "创建时间"}}', align:'center'}
                ]],
                response: {
                    statusName: 'status' //数据状态的字段名称，默认：code
                    , statusCode: 200 //成功的状态码，默认：0
                    , msgName: 'msg' //状态信息的字段名称，默认：msg
                    , countName: 'count' //数据总数的字段名称，默认：count
                    , dataName: 'datas' //数据列表的字段名称，默认：data
                }
            });
            //出入金信息
            tableIns_Money= table.render({
                elem: '#deposit_table'
                ,url: '/sale/ib/deposit/list' //数据接口
                ,page: true //开启分页
                ,where:{
                    ibid:ib_id
                }
                ,method:'post'
                ,cols: [[ //表头
                    {field: 'order_no', title: '{{ Lang.table_order_no || "订单编号"}}', align:'center'}
                    ,{field: 'account_no', title: '{{ Lang.table_source_account_no || "账号"}}', align:'center'}
                    ,{field: 'channel_type', title: '{{ Lang.table_cause || "资金类型"}}',align:'center',templet:function(d){
                        if(d.channel_type) {
                            return fundsTypeMap[d.channel_type];
                        }else{
                            return "";
                        }
                        }}
                    ,{field: 'amount', title: '{{ Lang.table_amount_3 || "申请金额(USD)"}}', align:'center',templet:function(d){
                        if(d.amount){
                            return d.amount / 100;
                        }else{
                            return "";
                        }

                        }}
                    ,{field: 'status', title: '{{ Lang.table_state || "订单状态"}}', align:'center',templet:function(d){
                        if(d.status) {
                            return orderStateMap[d.status];
                        }else{
                            return "";
                        }
                        }}
                    ,{field: 'remark', title: '{{ Lang.table_remark || "处理备注"}}', align:'center'}
                    ,{field: 'gmt_create', title: '{{ Lang.table_gmt_create_1 || "创建时间"}}', align:'center'}
                ]],
                response: {
                    statusName: 'status' //数据状态的字段名称，默认：code
                    , statusCode: 200 //成功的状态码，默认：0
                    , msgName: 'msg' //状态信息的字段名称，默认：msg
                    , countName: 'count' //数据总数的字段名称，默认：count
                    , dataName: 'datas' //数据列表的字段名称，默认：data
                }
            });
            //转账信息
            tableIns_transform= table.render({
                elem: '#transfer_table'
                ,url: '/sale/ib/transfer/list' //数据接口
                ,where:{
                    ibid:ib_id
                }
                ,page: true //开启分页
                ,method:'post'
                ,cols: [[ //表头

                    {field: 'order_no', title: '{{ Lang.table_order_no || "订单编号"}}', align:'center'}
                    ,{field: 'account_no', title: '{{ Lang.table_account_no || "转出账号"}}', align:'center'}
                    ,{field: 'target_account_no', title: '{{ Lang.table_target_account_no || "转入账号"}}',align:'center'}
                    ,{field: 'amount', title: '{{ Lang.table_amount_2 || "转账金额(USD)"}}', align:'center',templet:function(d){
                          return d.amount / 100;
                        }}
                    ,{field: 'status', title: '{{ Lang.table_state || "订单状态"}}', align:'center',templet:function(d){
                        if(d.status) {
                            return orderStateMap[d.status];
                        }else{
                            return "";
                        }
                        }}
                    ,{field: 'gmt_create', title: '{{ Lang.table_gmt_create_1 || "创建时间"}}', align:'center'}
                ]],
                response: {
                    statusName: 'status' //数据状态的字段名称，默认：code
                    , statusCode: 200 //成功的状态码，默认：0
                    , msgName: 'msg' //状态信息的字段名称，默认：msg
                    , countName: 'count' //数据总数的字段名称，默认：count
                    , dataName: 'datas' //数据列表的字段名称，默认：data
                }
            });
            //返利信息
            tableIns_rebate= table.render({
                elem: '#rebate_table'
                ,url: '/sale/ib/rebate/list' //数据接口
                ,where:{
                    ibid:ib_id
                }
                ,page: true //开启分页
                ,method:'post'
                ,cols: [[ //表头
                    {field: 'rebate_date', title: '{{ Lang.table_rebate_date || "返利日期"}}', align:'center',templet:function(d){
                        if(d.rebate_date){
                            return d.rebate_date.substring(0,10);
                        }else{
                            return "";
                        }
                        }},
                    {field: 'daily_amount', title: '{{ Lang.table_amount_4 || "返利金额"}}', align:'center', templet:function(d){
                        if(d.daily_amount){
                            return d.daily_amount / 100;
                        }else{
                            return 0;
                        }

                        }}
                ]],
                response: {
                    statusName: 'status' //数据状态的字段名称，默认：code
                    , statusCode: 200 //成功的状态码，默认：0
                    , msgName: 'msg' //状态信息的字段名称，默认：msg
                    , countName: 'count' //数据总数的字段名称，默认：count
                    , dataName: 'datas' //数据列表的字段名称，默认：data
                }
            });
            //返佣信息
            tableIns_commission= table.render({
                elem: '#commission_table'
                ,url: '/sale/ib/commission/list' //数据接口
                ,where:{
                    ibid:ib_id
                }
                ,page: true //开启分页
                ,method:'post'
                ,cols: [[ //表头
                    {field: 'gmt_create', title: '{{ Lang.table_change_time_1 || "返佣时间"}}',align:'center'},
                    {field: 'account_no', title: '{{ Lang.table_account_no_1 || "代理账号"}}', align:'center'},
                    {field: 'source_account_no', title: '{{ Lang.table_source_account_no_1 || "客户账号"}}', align:'center'},
                    {field: 'source_account_type', title: '{{ Lang.table_source_account_type_1 || "客户账户类型"}}', align:'center',templet:function(d){
                        if(d.source_account_type) {
                            return accountTypeMap[d.source_account_type];
                        }else{
                            return "";
                        }
                        }},
                    {field: 'source_account_full_name', title: '{{ Lang.table_customer_name_1 || "客户姓名"}}', align:'center'},
                    {field: 'trading_symbol', title: '{{ Lang.table_trading_symbol || "交易品种"}}', align:'center'},
                    {field: 'trading_volume', title: '{{ Lang.table_trading_volume || "交易量"}}', align:'center',templet:function(d){
                        if(d.trading_volume){
                            return d.trading_volume / 100;
                        }else{
                            return 0;
                        }
                        }},
                    {field: 'amount', title: '{{ Lang.table_commission_amount || "返佣金额(USD)"}}', align:'center',templet:function(d){
                        if(d.amount){
                            return d.amount /100;
                        }else{
                            return 0;
                        }
                        }},

                ]],
                response: {
                    statusName: 'status' //数据状态的字段名称，默认：code
                    , statusCode: 200 //成功的状态码，默认：0
                    , msgName: 'msg' //状态信息的字段名称，默认：msg
                    , countName: 'count' //数据总数的字段名称，默认：count
                    , dataName: 'datas' //数据列表的字段名称，默认：data
                }
            });
        });
    </script>

{% endblock %}