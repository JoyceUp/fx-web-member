{% extends '../../common/layouts/layout.tpl' %}

{% block css_assets %}
    <style>
    .layui-table-cell{
    text-overflow: inherit;
    }
    </style>
{% endblock %}

{% block js_assets %}
    <script>
        var position = new Object();
        {% for at in Lang.select.sale.position %}
        position[{{ at.value }}] = "{{ at.label }}";
        {% endfor %}

        var account_type = new Object();
        {% for at in Lang.select.sale.account_type %}
        account_type[{{ at.value }}] = '{{ at.label }}';
        {% endfor %}

        //查看详情
        var isOpen = false;
        function showDetail(date){
            //销售提成明细(来源于非直连客户收益[返佣和返利]);page: 代理客户交易提成
            layer.open({
                type: 1,
                title: "{{ Lang.dialog_bonus_details || "客户经理提成明细" }}",
                area: ['80%', '60%'], //宽高
                content: $("#detail"),
                cancel: function(index, layero){
                    isOpen = false;
                    layer.close(index)
                    return false;
                }
            });

            var table = layui.table;
          table.render({
                elem:"#list_ecn"
                ,url:'/sale/bonus/common_sale_reward/list_ecn'
                ,method:'post'
                ,where:{"gmt_create":date}
                ,page:true
                ,cols:[[
                    {field:'cloes_time',title:'{{ Lang.table_close_time || "平仓时间" }}',align:"center"},
                    {field:'source_account_no',title:'{{ Lang.table_source_account_no_1 || "客户账号" }}',align:"center"},
                    {field:'source_account_type',title:'{{ Lang.table_source_account_type || "账户类型" }}',align:"center",templet:function(d){
                            if (d.source_account_type) {
                                return account_type[d.source_account_type];
                            } else {
                                return "{{ Lang.table_unknown || "未知" }}";
                            }
                        }},
                    {field:'source_account_full_name',title:'{{ Lang.table_customer_name_1 || "客户姓名" }}',align:"center"},
                    {field:'trading_symbol',title:'{{ Lang.table_trading_symbol || "交易品种" }}',align:"center"},
                    {field:'trading_volume',title:'{{ Lang.table_trading_volume || "交易量" }}',align:"center",templet:function(d){
                        if(d.trading_volume){
                            return (d.trading_volume / 100).toFixed(2) +'{{ Lang.form_hand||"手"}}';
                        }else{
                            return "";
                        }
                        }},
                    {field:'commission_rate',title:'{{ Lang.table_earning_rate || "提成比例" }}',align:"center",templet:function(d){
                        if(d.commission_rate){
                            return d.commission_rate  +"{{ Lang.table_commission_rate || "美元/手"}}";
                        }else{
                            return "";
                        }
                        }},
                    {field:'amount',title:'{{ Lang.table_amount_5 || "提成金额(USD)" }}',align:"center",templet:function(d){
                        if(d.amount){
                            return d.amount/100;
                        }else{
                            return 0;
                        }
                        }},
                  {field:'account_no',title:'{{ Lang.table_account_no_1 || "代理账号" }}',align:"center"},
                  {field:'full_name',title:'{{ Lang.table_ib_name || "代理姓名" }}',align:"center"}

                ]],
               response: {
                   statusName: 'status' //数据状态的字段名称，默认：code
                   , statusCode: 200 //成功的状态码，默认：0
                   , msgName: 'msg' //状态信息的字段名称，默认：msg
                   , countName: 'count' //数据总数的字段名称，默认：count
                   , dataName: 'datas' //数据列表的字段名称，默认：data
               }

            });


            //客户经理(销售) 提成明细 之 代理收益提成
            table.render({
                elem:"#list_common"
                ,url:'/sale/bonus/common_sale_reward/list_common'
                ,method:'post'
                ,where:{"gmt_create":date}
                ,page:true
                ,cols:[[
                    {field:'source_account_no',title:'{{ Lang.table_ib_account || "代理账户" }}',align:"center"},
                    {field:'source_account_type',title:'{{ Lang.table_source_account_type || "账户类型" }}',align:"center",templet:function(d){
                            if (d.source_account_type) {
                                return account_type[d.source_account_type];
                            } else {
                                return "{{ Lang.table_unknown || "未知" }}";
                            }
                        }},
                    {field:'source_account_full_name',title:'{{ Lang.table_ib_name || "代理姓名"}}',align:"center"},
                    {field:'income',title:'{{ Lang.table_ib_income || "代理收益(USD)"}}',align:"center",templet:function(d){
                        if(d.income){
                            return d.income/100;
                        }else{
                            return 0;
                        }
                     }},
                    {field:'rate',title:'{{ Lang.table_earning_rate || "提成比例"}}',align:"center",templet:function(d){
                            if(d.rate){
                                return d.rate/10000  +"%";
                            }else{
                                return "";
                            }
                        }},
                    {field:'amount',title:'{{ Lang.table_amount_5 || "提成金额(USD)"}}',align:"center",templet:function(d){
                            if(d.amount){
                                return d.amount/100;
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


        }

        //客户总监提成明细
        var department_detail_table;
        var department_detail_table_common;
        function show_department_Detail(date){
            layer.open({
                type: 1,
                title: "{{ Lang.dialog_bonus_details_department || "客户总监提成明细" }}",
                area: ['80%', '60%'], //宽高
                content: $("#department_detail"),
                cancel: function(index, layero){
                    isOpen = false;
                    layer.close(index)
                    return false;
                }
            });
            var table = layui.table;
            department_detail_table = table.render({
                elem:"#department_list_ecn"
                ,url:'/sale/bonus/department_sale_reward/list_ecn'
                ,method:'post'
                ,where:{"gmt_create":date}
                ,page:true
                ,cols:[[
                    {field:'cloes_time',title:'{{ Lang.table_close_time || "平仓时间" }}',align:"center"},
                    {field:'source_account_no',title:'{{ Lang.table_source_account_no_1 || "客户账号" }}',align:"center"},
                    {field:'source_account_type',title:'{{ Lang.table_source_account_type || "账户类型" }}',align:"center",templet:function(d){
                            if (d.source_account_type) {
                                return account_type[d.source_account_type];
                            } else {
                                return "{{ Lang.table_unknown || "未知" }}";
                            }
                        }},
                    {field:'source_account_full_name',title:'{{ Lang.table_customer_name_1 || "客户姓名"}}',align:"center"},
                    {field:'trading_symbol',title:'{{ Lang.table_trading_symbol || "交易品种"}}',align:"center"},
                    {field:'trading_volume',title:'{{ Lang.table_trading_volume || "交易量"}}',align:"center",templet:function(d){
                            if(d.trading_volume){
                                return (d.trading_volume / 100).toFixed(2) + '{{ Lang.form_hand||"手"}}';
                            }else{
                                return "";
                            }
                        }},
                    {field:'commission_rate',title:'{{ Lang.table_earning_rate || "提成比例"}}',align:"center",templet:function(d){
                            if(d.commission_rate){
                                return d.commission_rate  +"{{ Lang.table_commission_rate || "美元/手"}}";
                            }else{
                                return "";
                            }
                        }},
                    {field:'amount',title:'{{ Lang.table_amount_5 || "提成金额(USD)"}}',align:"center",templet:function(d){
                            if(d.amount){
                                return d.amount/100;
                            }else{
                                return 0;
                            }
                        }},
                    {field:'account_no',title:'{{ Lang.table_account_no_1 || "代理账号" }}',align:"center"},
                    {field:'full_name',title:'{{ Lang.table_ib_name || "代理姓名" }}',align:"center"}
                ]],
                response: {
                    statusName: 'status' //数据状态的字段名称，默认：code
                    , statusCode: 200 //成功的状态码，默认：0
                    , msgName: 'msg' //状态信息的字段名称，默认：msg
                    , countName: 'count' //数据总数的字段名称，默认：count
                    , dataName: 'datas' //数据列表的字段名称，默认：data
                }
            });


            //客户总监提成明细 之 销售收益提成
            department_detail_table_common = table.render({
                elem:"#department_list_common"
                ,url:'/sale/bonus/department_sale_reward/list_common'
                ,method:'post'
                ,where:{"gmt_create":date}
                ,page:true
                ,cols:[[
                    {field:'source_account_no',title:'{{ Lang.form_text_sales_account_no || "销售账号" }}',align:"center"},
                    {field:'source_account_full_name',title:'{{ Lang.form_placeholder_sales_name || "销售姓名" }}',align:"center"},
                    {field:'income',title:'{{ Lang.table_sale_bonus || "代理收益(USD)" }}',align:"center",templet:function(d){
                            if(d.income){
                                return d.income/100;
                            }else{
                                return 0;
                            }
                        }},
                    {field:'rate',title:'{{ Lang.table_earning_rate || "提成比例"}}',align:"center",templet:function(d){
                            if(d.rate){
                                return d.rate/10000  +"%";
                            }else{
                                return "";
                            }
                        }},
                    {field:'amount',title:'{{ Lang.table_amount_5 || "提成金额(USD)"}}',align:"center",templet:function(d){
                            if(d.amount){
                                return d.amount/100;
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
            //销售提成明细(来源于非直连客户收益[返佣和返利]);page: 代理客户交易提成





        }

        //提成列表
        var tableIns;

        layui.use(['form', 'laydate', 'table','element'], function () {
            var element = layui.element;
            //日期
            var laydate = layui.laydate;
            laydate.render({
                elem: '#start_time'
                , type: 'date'
                , format: 'yyyy-MM-dd'
            });
            laydate.render({
                elem: '#end_time'
                , type: 'date'
                , format: 'yyyy-MM-dd'
            });

            //填充表单数据
            var table = layui.table;
            if(window.user.department_sales == 1 && window.user.common_sales == 2) {
                tableIns = table.render({
                    elem: '#test'
                    , url: '/sale/bonus/info'
                    , cols: [[
                        {
                            field: 'change_time', title: '{{ Lang.table_change_time || "提成日期" }}', align: 'center', templet: function (d) {
                                if (d.statistics) {
                                    return "{{ Lang.table_total_text || "合计" }}";
                                }
                                if (d.change_time) {
                                    return d.change_time.substring(0, 10);
                                }
                            }
                        }
                        {#总监级别的，显示下面类容#}
                        , {
                            field: 'department_leader_amount',
                            title: '{{ Lang.table_department_leader_amount || "客户总监提成(USD)" }}',
                            align: 'center',
                            templet: function (d) {

                                if (d.statistics) {
                                    return d.sum_reward_amount_by_cause2 / 100;
                                } else {
                                    if (d.department_leader_amount) {
                                        return '<a onclick="show_department_Detail(\'' + d.change_time.substring(0, 10) + '\')"  href="javascript:;">' + d.department_leader_amount / 100 + '</a>'
                                        //return d.department_leader_amount / 100
                                    } else {
                                        return '0';
                                    }
                                }
                            }
                        }
                    ]]
                    , page: true
                    , method: 'post'
                    , response: {
                        statusName: 'status' //数据状态的字段名称，默认：code
                        , statusCode: 200 //成功的状态码，默认：0
                        , msgName: 'msg' //状态信息的字段名称，默认：msg
                        , countName: 'count' //数据总数的字段名称，默认：count
                        , dataName: 'datas' //数据列表的字段名称，默认：data
                    }
                });
            }else if(window.user.department_sales == 1 && window.user.common_sales == 1){
                tableIns = table.render({
                    elem: '#test'
                    , url: '/sale/bonus/info'
                    , cols: [[
                        {
                            field: 'change_time', title: '{{ Lang.table_change_time || "提成日期" }}', align: 'center', templet: function (d) {
                                if (d.statistics) {
                                    return "{{ Lang.table_total_text || "合计" }}";
                                }
                                if (d.change_time) {
                                    return d.change_time.substring(0, 10);
                                }
                            }
                        }
                        , {
                            field: 'common_sales_amount', title: '{{ Lang.table_common_sales_amount || "客户经理提成(USD)" }}', align: 'center', templet: function (d) {
                                if (d.statistics) {
                                    return d.sum_reward_amount_by_cause / 100;
                                } else {

                                    if (d.common_sales_amount) {
                                        return '<a onclick="showDetail(\'' + d.change_time.substring(0, 10) + '\')"  href="javascript:;">' + d.common_sales_amount / 100 + '</a>'
                                        //                                       return  d.common_sales_amount / 100
                                    } else {
                                        return '0';
                                    }
                                }
                            }

                        }{#总监级别的，显示下面类容#}
                        , {
                            field: 'department_leader_amount',
                            title: '{{ Lang.table_department_leader_amount || "客户总监提成(USD)" }}',
                            align: 'center',
                            templet: function (d) {

                                if (d.statistics) {
                                    return d.sum_reward_amount_by_cause2 / 100;
                                } else {
                                    if (d.department_leader_amount) {
                                        return '<a onclick="show_department_Detail(\'' + d.change_time.substring(0, 10) + '\')"  href="javascript:;">' + d.department_leader_amount / 100 + '</a>'
                                        //return d.department_leader_amount / 100
                                    } else {
                                        return '0';
                                    }
                                }
                            }
                        }
                        , {
                            field: 'amount', title: '{{ Lang.table_amount || "提成合计(USD)" }}', align: 'center', templet: function (d) {
                                if (d.statistics) {
                                    return d.sum_reward_amount / 100;
                                } else {
                                    if (d.amount) {
                                        return d.amount / 100
                                    } else {
                                        return '0';
                                    }
                                }
                            }
                        }
                    ]]
                    , page: true
                    , method: 'post'
                    , response: {
                        statusName: 'status' //数据状态的字段名称，默认：code
                        , statusCode: 200 //成功的状态码，默认：0
                        , msgName: 'msg' //状态信息的字段名称，默认：msg
                        , countName: 'count' //数据总数的字段名称，默认：count
                        , dataName: 'datas' //数据列表的字段名称，默认：data
                    }
                });
            }else {
                tableIns = table.render({
                    elem: '#test'
                    , url: '/sale/bonus/info'
                    , cols: [[
                        {
                            field: 'change_time', title: '{{ Lang.table_change_time || "提成日期" }}', align: 'center', templet: function (d) {
                                if (d.statistics) {
                                    return "{{ Lang.table_total_text || "合计" }}";
                                }
                                if (d.change_time) {
                                    return d.change_time.substring(0, 10);
                                }
                            }
                        }
                        , {
                            field: 'common_sales_amount', title: '{{ Lang.table_common_sales_amount || "客户经理提成(USD)" }}', align: 'center', templet: function (d) {
                                if (d.statistics) {
                                    return d.sum_reward_amount_by_cause / 100;
                                } else {

                                    if (d.common_sales_amount) {
                                        return '<a onclick="showDetail(\'' + d.change_time.substring(0, 10) + '\')"  href="javascript:;">' + d.common_sales_amount / 100 + '</a>'
 //                                       return  d.common_sales_amount / 100
                                    } else {
                                        return '0';
                                    }
                                }
                            }
                        }
                    ]]
                    , page: true
                    , method: 'post'
                    , response: {
                        statusName: 'status' //数据状态的字段名称，默认：code
                        , statusCode: 200 //成功的状态码，默认：0
                        , msgName: 'msg' //状态信息的字段名称，默认：msg
                        , countName: 'count' //数据总数的字段名称，默认：count
                        , dataName: 'datas' //数据列表的字段名称，默认：data
                    }
                });
            }
            //监听搜索按钮
            var form = layui.form;
            form.on('submit(search_btn)', function (data) {
                if (data.field.start_time && data.field.end_time) {
                    if (new Date(data.field.start_time).getTime() > new Date(data.field.end_time).getTime()) {
                        layer.alert("{{ Lang.alert_start_time_more_than_the_end_time || "开始时间 不能大于 结束时间" }}", {
                            title: '{{ Lang.page_msg_h3 || "提示：" }}'
                        });
                        return false;
                    }
                }
                search(data.field);
                return false;
            });

        });

        function search(search_form_data) {
            var start = search_form_data.start_time;
            var end = search_form_data.end_time;
            if (start) {
                start = start + " 00:00:00";
            } else {
                start = '';
            }

            if (end) {
                end = end + " 23:59:59"
            } else {
                end = '';
            }
            tableIns.reload({
                where: { //设定异步数据接口的额外参数，任意设
                    start_time: start
                    , end_time: end
                }
                , page: {
                    curr: 1 //重新从第 1 页开始
                }
            });
        }

        function reload(){
            tableIns.reload({
                where:{
                },
                page:{
                    curr:1
                }
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
                        {{ Lang.page_rebate_bonus_title || "提成列表" }}
                    </div>
                    <div id="search_box">
                        <form class="layui-form" action="">

                            <div class="layui-input-inline">
                                <input class="layui-input" id="start_time" name="start_time" placeholder="{{ Lang.form_placeholder_start_time || "开始时间" }}" type="text" value="" >
                            </div>
                            <div class="layui-input-inline">
                                -
                            </div>
                            <div class="layui-input-inline">
                                <input class="layui-input" id="end_time" name="end_time" placeholder="{{ Lang.form_placeholder_end_time || "结束时间" }}" type="text" value="">
                            </div>

                            <div class="layui-input-inline">
                                <button class="layui-btn" lay-submit="" lay-filter="search_btn" onclick="return false;">{{ Lang.btn_search || "查询" }}</button>
                                <button type="reset" class="layui-btn layui-btn-primary" onclick="reload()">{{ Lang.btn_reset || "清空" }}</button>
                            </div>
                        </form>
                    </div>
                </div>
                <div class="main_page_Info">
                    <table class="layui-hide" id="test"></table>
                    <div class="page">
                    </div>
                </div>
            </div>
        </div>
    </div>


    <div id="detail" style="display:none">
        <div class="main_page_Info">
            <div class="layui-tab layui-tab-brief" lay-filter="sales_detail">
                <ul class="layui-tab-title">
                    <li class="layui-this" lay-id=="list_ecn_tab">代理客户交易提成</li>
                    <li>代理收益提成</li>
                </ul>
                <div class="layui-tab-content">
                    <div class="layui-tab-item layui-show">
                        <table class="layui-hide" id="list_ecn"></table>
                        <div class="page">
                        </div>
                    </div>
                    <div class="layui-tab-item">
                        <table class="layui-hide" id="list_common"></table>
                        <div class="page">
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>

    <div id="department_detail" style="display:none">
        <div class="main_page_Info">
            <div class="layui-tab layui-tab-brief" lay-filter="sales_detail1">
                <ul class="layui-tab-title">
                    <li class="layui-this" lay-id=="department_ecn_tab">部门客户交易提成</li>
                    <li>销售收益提成</li>
                </ul>
                <div class="layui-tab-content">
                    <div class="layui-tab-item layui-show">
                        <table class="layui-hide" id="department_list_ecn"></table>
                        <div class="page">
                        </div>
                    </div>
                    <div class="layui-tab-item">
                        <table class="layui-hide" id="department_list_common"></table>
                        <div class="page">
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>

{% endblock %}
