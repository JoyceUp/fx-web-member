{% extends '../../common/layouts/layout.tpl' %}

{% block css_assets %}
    <style>
    .layui-table-cell{
        text-overflow: inherit;
    }
    #rebate_search_box,
    #department_ecn_search_box,
    #department_common_search_box,
    #commonrebate_ecn_search_box,
    #commonrebate_common_search_box,
    #commission_search_box{
        padding: 0 0 0 15px;
    }
   /* .results_center .layui-table-cell{
        overflow: inherit;
        word-break:break-all;
        display: block;
        white-space: inherit;
    }*/
    </style>
{% endblock %}

{% block js_assets %}
    <script>
        var position = new Object();
        {% for at in Lang.select.sale.position %}
        position[{{ at.value }}] = "{{ at.label }}";
        {% endfor %}

        var sales_state = new Object();
        {% for at in Lang.select.sale.sales_state %}
        sales_state[{{ at.value }}] = '{{ at.label }}';
        {% endfor %}

        var source_account_type = new Object();
        {% for at in Lang.select.sale.account_type %}
        source_account_type[{{ at.value }}] = '{{ at.label }}';
        {% endfor %}

        //查看详情
        var isOpen = false;


        //提成列表
        var tableIns,
            tableInsTwo,
            tableInsThree,
            tableInsFour,
            tableInsFive,
            tableInsSix,
            tableInsSeven;

        layui.use(['form', 'laydate', 'table','element'], function () {
            var element = layui.element;
            //日期
            var laydate = layui.laydate;
            laydate.render({
                elem: '#start_time'
                , type: 'month'
                , format: 'yyyy-MM-dd'
            });


            //填充表单数据
            var table = layui.table;

            tableIns = table.render({
                  page: true
                , method: 'post'
                , response: {
                    statusName: 'status' //数据状态的字段名称，默认：code
                    , statusCode: 200 //成功的状态码，默认：0
                    , msgName: 'msg' //状态信息的字段名称，默认：msg
                    , countName: 'count' //数据总数的字段名称，默认：count
                    , dataName: 'datas' //数据列表的字段名称，默认：data
                 }
                //  ,
                // done: function(res){
                //     if( res.datas[0].leader_reward !== 1){
                //         $("[data-field='leader_reward']").css('display','none');
                //     }
                // }
                , elem: '#test'
                , url: '/sale/results/list'
                , cols: [[
                    {field: 'performance_date', title: '{{  "年月" }}',align:'center'}
                    ,{field: 'account_no', title: '{{  "销售账号"}}', align:'center'}
                    ,{field: 'full_name', title: '{{ "销售姓名"}}', align:'center'}
                    ,{field: 'sales_state', title: '{{  "销售类别"}}',align:'center', templet:function (d) {
                            return sales_state[d.sales_state] || '';
                        }}
                    ,{field: 'position', title: '{{  "职位名称"}}',align:'center', templet:function (d) {
                            return position[d.position] || '';
                        }}
                    ,{field: 'dept_name', title: '{{   "部门"}}', align:'center'}
                    ,{field: 'team_name', title: '{{ "组别"}}',align:'center', templet:function (d) {
                            if(d.position == 1){
                                d.team_name = ''
                            }
                            return d.team_name || ""
                        }}
                    ,{field: 'rebate', title: '{{  "余额返利（USD）"}}',align:'center', templet:function(d){
                            var rate = d.rebate;
                            var rateStr = rate.toString();
                            if (rateStr.indexOf('.') > -1) {
                                rate = toFixed(rate, 2);
                            }
                            return rate
                        }}
                    ,{field: 'commission', title: '{{   "交易返佣（USD）"}}',align:'center'}
                    ,{field: 'sales_reward', title: '{{ "销售提成（USD）"}}',align:'center', templet:function(d){
                            var rate = d.sales_reward;
                            var rateStr = rate.toString();
                            if (rateStr.indexOf('.') > -1) {
                                rate = toFixed(rate, 2);
                            }
                            return rate
                        }}
                    ,{field: 'leader_reward', title: '{{ "总监提成（USD）"}}',align:'center', templet:function(d){ ;
                        var rate = d.leader_reward;
                        var rateStr = rate.toString();
                        if(d.position == 1 ){
                            if (rateStr.indexOf('.') > -1) {
                                rate = toFixed(rate, 2);
                            }
                            return rate
                        }else{

                            rate = ""
                            return rate
                        }
                        }}
                    ,{field: 'total', title: '{{ "本月合计（USD）"}}',align:'center', templet:function(d){
                            var rate = d.total;
                            var rateStr = rate.toString();
                            if (rateStr.indexOf('.') > -1) {
                                rate = toFixed(rate, 2);
                            }
                            return rate
                        }}
                    ,{field: 'sum_trade_volume', title: '{{ "查看" }}', align:'center',templet:function (d) {
                            return '<a onclick="showDetail(\'' + d.performance_date + '\' , \'' + d.account_no + '\', \'' + d.position + '\')" href="javascript:;">' + "明细" + '</a>'
                        }}
                ]]

            });
            //监听搜索按钮
            var form = layui.form;
            form.on('submit(search_btn)', function (data) {
                if(data.field.start_time) {
                    data.field.start_time = data.field.start_time + "-1"
                }else {
                }
                search(data.field,tableIns);
                return false;
            });
            form.on('submit(reload)', function (data) {
                reload(data.field,tableIns);
                return false;
            });

        });

        //获取月度详情
        function showDetail(time, account_no,  verificationposition) {
            //填充表单数据


            layer.open({
                type: 1,
                title: "{{   "业绩明细" }}",
                area: ['100%', '100%'], //宽高
                content: $("#detail")
            });

            var table = layui.table;

            table.render({

                elem: '#department_detail'
                , url: "/sale/results/detail"
                , method: 'post'
                , where: {
                    start_time: time + "-1 00:00:00",
                    end_time: time + " 23:59:59",
                    account_no: account_no
                }
                , verificationposition:verificationposition
                ,done: function(verificationposition){
                    // if( verificationposition.datas[0].position !== 1){
                    //     $('#layui-layer1').find($("[data-field='leader_reward']")).css('display','none');
                    // }
                }
                , cols: [[
                    {field: 'performance_date', title: '{{  "日期" }}',align:'center'}
                    ,{field: 'account_no', title: '{{  "销售账号"}}', align:'center'}
                    ,{field: 'full_name', title: '{{ "销售姓名"}}', align:'center'}
                    ,{field: 'sales_state', title: '{{  "销售类别"}}',align:'center', templet:function (d) {
                            return sales_state[d.sales_state] || '';
                        }}
                    ,{field: 'position', title: '{{  "职位名称"}}',align:'center', templet:function (d) {
                            return position[d.position] || '';
                        }}
                    ,{field: 'dept_name', title: '{{   "部门"}}', align:'center'}
                    ,{field: 'team_name', title: '{{ "组别"}}',align:'center', templet:function (d) {
                            if(d.position == 1){
                                d.team_name = '-'
                            }
                            return d.team_name || '-'
                        }}
                    ,{field: 'rebate', title: '{{  "余额返利（USD）"}}',align:'center',templet:function (d) {
                            return '<a onclick="showDetailRebate(\'' + d.performance_date + '\' , \'' + d.account_no + '\')" href="javascript:;">' + d.rebate + '</a>'
                        }}
                    ,{field: 'commission', title: '{{   "交易返佣（USD）"}}',align:'center',templet:function (d) {
                            return '<a onclick="showDetailCommission(\'' + d.performance_date + '\' , \'' + d.account_no + '\')" href="javascript:;">' + d.commission + '</a>'
                        }}
                    ,{field: 'sales_reward', title: '{{ "销售提成（USD）"}}',align:'center',templet:function (d) {
                            return '<a onclick="showDetailSalesReward(\'' + d.performance_date + '\' , \'' + d.owner_id + '\')" href="javascript:;">' + d.sales_reward + '</a>'
                        }}
                    ,{field: 'leader_reward', title: '{{ "总监提成（USD）"}}',align:'center',templet:function (d) {
                            return '<a onclick="showDetailLeaderReward(\'' + d.performance_date + '\' , \'' + d.owner_id + '\')" href="javascript:;">' + d.leader_reward + '</a>'
                        },}
                    ,{field: 'total', title: '{{ "本日合计（USD）"}}',align:'center', templet:function(d){
                            var rate = d.total;
                            var rateStr = rate.toString();
                            if (rateStr.indexOf('.') > -1) {
                                rate = toFixed(rate, 2);
                            }
                            return rate
                        }}
                ]]
                , page: true
                , response: {
                    statusName: 'status' //数据状态的字段名称，默认：code
                    , statusCode: 200 //成功的状态码，默认：0
                    , msgName: 'msg' //状态信息的字段名称，默认：msg
                    , countName: 'count' //数据总数的字段名称，默认：count
                    , dataName: 'datas' //数据列表的字段名称，默认：data
                }

            });

        }

        //获取余额返利详情
        function showDetailRebate(performance_date,account_no) {
            //填充表单数据

            layui.use(['form', 'table'], function () {
                layer.open({
                    type: 1,
                    title: "{{ "查看返利明细" }}",
                    area: ['80%', '600px'], //宽高
                    content: $("#showDetailRebate")
                });
                var table = layui.table;
                tableInsTwo = table.render({
                    elem: '#department_showDetailRebate'
                    , url: "/sale/results/rebate"
                    , method: 'post'
                    , where: {
                        start_time: performance_date + " 00:00:00",
                        account_no: account_no,
                    }
                    , cols: [[
                        {field: 'source_account_no', title: '{{  "客户账号" }}', align: 'center'}
                        , {field: 'source_account_full_name', title: '{{  "客户姓名"}}', align: 'center'}
                        , {
                            field: 'source_account_type', title: '{{ "账户类型"}}', align: 'center', templet: function (d) {
                                return source_account_type[d.source_account_type] || '';
                            }
                        }
                        , {
                            field: 'source_account_balance',
                            title: '{{  "账户余额（USD）"}}',
                            align: 'center',
                            templet: function (d) {
                                return d.source_account_balance / 100;
                            }
                        }
                        , {
                            field: 'rate', title: '{{  "年化比例"}}', align: 'center', templet: function (d) {
                                return d.rate / 10000 + "%";
                            }
                        }
                        , {
                            field: 'amount', title: '{{   "余额返利（USD）"}}', align: 'center', templet: function (d) {
                                return d.amount / 100;
                            }
                        }
                    ]]
                    , page: true
                    , response: {
                        statusName: 'status' //数据状态的字段名称，默认：code
                        , statusCode: 200 //成功的状态码，默认：0
                        , msgName: 'msg' //状态信息的字段名称，默认：msg
                        , countName: 'count' //数据总数的字段名称，默认：count
                        , dataName: 'datas' //数据列表的字段名称，默认：data
                    }
                });
                //监听搜索按钮
                var form = layui.form;
                form.on('submit(rebate_search_btn)', function (data) {
                    search(data.field,tableInsTwo,account_no,performance_date);
                    return false;
                });
                form.on('submit(reload_two)', function (data) {
                    reload(data.field,tableInsTwo,account_no,performance_date);
                    return false;
                });
            });
        }

        //获取交易返佣详情
        function showDetailCommission(performance_date,account_no) {
            //填充表单数据

            layui.use(['form', 'table'], function () {
                layer.open({
                    type: 1,
                    title: "{{ "交易返佣明细" }}",
                    area: ['80%', '600px'], //宽高
                    content: $("#showDetailCommission"),
                });

                var table = layui.table;
                tableInsThree = table.render({
                    elem: '#department_showDetailCommission'
                    , url: "/sale/results/commission"
                    , method: 'post'
                    , where: {
                        start_time: performance_date + " 00:00:00",
                        account_no: account_no,
                    }
                    , cols: [[
                        {field: 'mt4_order_no', title: '{{  "订单号" }}', align: 'center'}
                        , {field: 'source_account_no', title: '{{  "客户账号"}}', align: 'center'}
                        , {field: 'source_account_full_name', title: '{{ "客户姓名"}}', align: 'center'}
                        , {
                            field: 'source_account_type',
                            title: '{{  "账户类型"}}',
                            align: 'center',
                            templet: function (d) {
                                return source_account_type[d.source_account_type] || '';
                            }
                        }
                        , {field: 'trading_symbol', title: '{{  "交易品种"}}', align: 'center'}
                        , {
                            field: 'trading_volume', title: '{{   "交易手数"}}', align: 'center', templet: function (d) {
                                return d.trading_volume / 100;
                            }
                        }
                        , {
                            field: 'commission_rate', title: '{{ "返佣比例"}}', align: 'center', templet: function (d) {
                                return d.commission_rate + "USD/手";
                            }
                        }
                        , {
                            field: 'amount', title: '{{  "返佣金额（USD）"}}', align: 'center', templet: function (d) {
                                return d.amount / 100;
                            }
                        }
                        //,{field: 'commission', title: '{{   "平仓时间"}}',align:'center'}
                    ]]
                    , page: true
                    , response: {
                        statusName: 'status' //数据状态的字段名称，默认：code
                        , statusCode: 200 //成功的状态码，默认：0
                        , msgName: 'msg' //状态信息的字段名称，默认：msg
                        , countName: 'count' //数据总数的字段名称，默认：count
                        , dataName: 'datas' //数据列表的字段名称，默认：data
                    }
                });
                //监听搜索按钮
                var form = layui.form;
                form.on('submit(commission_search_btn)', function (data) {
                    search(data.field,tableInsThree,account_no,performance_date);
                    return false;
                });
                form.on('submit(reload_three)', function (data) {
                    reload(data.field,tableInsThree,account_no,performance_date);
                    return false;
                });
            });
        }
        //获取销售提成详情
        function showDetailSalesReward(gmt_create,owner_id) {
            //填充表单数据
            layui.use(['form', 'table'], function () {
                layer.open({
                    type: 1,
                    title: "{{ "销售提成明细" }}",
                    area: ['80%', '600px'], //宽高
                    content: $("#showDetailCommonRebate"),
                });

                var table = layui.table;
                var tableTwo = layui.table;
                tableInsFour = table.render({
                    elem: '#CommonRebate_RewardRebateCommon'
                    , url: "/sale/results/commissionRewardEcn"
                    , method: 'post'
                    , where: {
                        gmt_create: gmt_create + " 00:00:00",
                        owner_id: owner_id,
                    }
                    , cols: [[
                        {field: 'mt4_order_no', title: '{{  "订单号" }}',align:'center'}
                        ,{field: 'source_account_no', title: '{{  "客户账号"}}', align:'center'}
                        ,{field: 'source_account_full_name', title: '{{ "客户姓名"}}', align:'center'}
                        ,{field: 'source_account_type', title: '{{  "账户类型"}}',align:'center', templet:function (d) {
                                return source_account_type[d.source_account_type] || '';
                            }}
                        ,{field: 'trading_symbol', title: '{{  "交易品种"}}',align:'center'}
                        ,{field: 'trading_volume', title: '{{   "交易手数"}}', align:'center', templet:function (d){
                                return d.trading_volume / 100;
                            }}
                        ,{field: 'commission_rate', title: '{{ "提成比例"}}',align:'center', templet:function (d){
                                return d.commission_rate + "USD/手";
                            }}
                        ,{field: 'amount', title: '{{  "提成金额(USD)"}}',align:'center', templet:function (d){
                                return d.amount / 100;
                            }}
                        ,{field: 'cloes_time', title: '{{   "平仓时间"}}',align:'center'}
                        ,{field: 'account_no', title: '{{ "代理账号"}}',align:'center'}
                        ,{field: 'full_name', title: '{{ "代理姓名"}}',align:'center'}
                    ]]
                    , page: true
                    , response: {
                        statusName: 'status' //数据状态的字段名称，默认：code
                        , statusCode: 200 //成功的状态码，默认：0
                        , msgName: 'msg' //状态信息的字段名称，默认：msg
                        , countName: 'count' //数据总数的字段名称，默认：count
                        , dataName: 'datas' //数据列表的字段名称，默认：data
                    }
                });
                //监听搜索按钮
                var forma = layui.form;
                forma.on('submit(commonrebate_common_search_btn)', function (data) {
                    searchTwo(data.field,tableInsFour,owner_id,gmt_create);
                    return false;
                });
                forma.on('submit(reload_four)', function (data) {
                    reload(data.field,tableInsFour,owner_id,gmt_create);
                    return false;
                });
                tableInsFive = tableTwo.render({
                    elem: '#CommonRebate_RewardRebateEcn'
                    , url: "/sale/results/commissionRewardCommon"
                    , method: 'post'
                    , where: {
                        gmt_create: gmt_create + " 00:00:00",
                        owner_id: owner_id,
                    }
                    , cols: [[
                        {field: 'source_account_no', title: '{{  "代理账号" }}',align:'center'}
                        ,{field: 'source_account_full_name', title: '{{  "代理姓名"}}', align:'center'}
                        ,{field: 'source_account_type', title: '{{  "账户类型"}}',align:'center', templet:function (d) {
                                return source_account_type[d.source_account_type] || '';
                            }}
                        ,{field: 'income', title: '{{  "代理收益（USD）"}}',align:'center', templet:function (d){
                                return d.income / 100;
                            }}
                        ,{field: 'rate', title: '{{   "提成比例"}}', align:'center', templet:function (d){
                                return d.rate / 10000 + "%";
                            }}
                        ,{field: 'amount', title: '{{  "提成金额(USD)"}}',align:'center',templet:function (d){
                                return d.amount / 100;
                            }}
                    ]]
                    , page: true
                    , response: {
                        statusName: 'status' //数据状态的字段名称，默认：code
                        , statusCode: 200 //成功的状态码，默认：0
                        , msgName: 'msg' //状态信息的字段名称，默认：msg
                        , countName: 'count' //数据总数的字段名称，默认：count
                        , dataName: 'datas' //数据列表的字段名称，默认：data
                    }

                });

                //监听搜索按钮
                var formb = layui.form;
                formb.on('submit(commonrebate_ecn_search_btn)', function (data) {
                    search(data.field,tableInsFive,owner_id,gmt_create);
                    return false;
                });
                formb.on('submit(reload_five)', function (data) {

                    reload(data.field,tableInsFive,owner_id,gmt_create);
                    return false;
                });
            });
        }
        //获取总监提成详情
        function showDetailLeaderReward(performance_date,account_no) {
            //填充表单数据
            layui.use(['form', 'table'], function () {
                layer.open({
                    type: 1,
                    title: "{{ "总监提成明细" }}",
                    area: ['80%', '600px'], //宽高
                    content: $("#showDetailDepartmentRebate"),
                });

                var table = layui.table;
                var tableTwo = layui.table;
                tableInsSix = table.render({
                    elem: '#Department_RewardRebateCommon'
                    , url: "/sale/results/DepartmentewardEcn"
                    , method: 'post'
                    , where: {
                        start_time: performance_date + " 00:00:00",
                        account_no: account_no,
                    }
                    , cols: [[
                        {field: 'mt4_order_no', title: '{{  "订单号" }}',align:'center'}
                        ,{field: 'source_account_no', title: '{{  "客户账号"}}', align:'center'}
                        ,{field: 'source_account_full_name', title: '{{ "客户姓名"}}', align:'center'}
                        ,{field: 'source_account_type', title: '{{  "账户类型"}}',align:'center', templet:function (d) {
                                return source_account_type[d.source_account_type] || '';
                            }}
                        ,{field: 'trading_symbol', title: '{{  "交易品种"}}',align:'center'}
                        ,{field: 'trading_volume', title: '{{   "交易手数"}}', align:'center', templet:function (d){
                                return d.trading_volume / 100;
                            }}
                        ,{field: 'commission_rate', title: '{{ "提成比例"}}',align:'center', templet:function (d){
                                return d.commission_rate + "USD/手";
                            }}
                        ,{field: 'amount', title: '{{  "提成金额(USD)"}}',align:'center', templet:function (d){
                                return d.amount / 100;
                            }}
                        ,{field: 'cloes_time', title: '{{   "平仓时间"}}',align:'center'}
                        ,{field: 'account_no', title: '{{ "代理账号"}}',align:'center'}
                        ,{field: 'full_name', title: '{{ "代理姓名"}}',align:'center'}
                    ]]
                    , page: true
                    , response: {
                        statusName: 'status' //数据状态的字段名称，默认：code
                        , statusCode: 200 //成功的状态码，默认：0
                        , msgName: 'msg' //状态信息的字段名称，默认：msg
                        , countName: 'count' //数据总数的字段名称，默认：count
                        , dataName: 'datas' //数据列表的字段名称，默认：data
                    }
                });
                //监听搜索按钮
                var forma = layui.form;
                forma.on('submit(department_common_search_btn)', function (data) {
                    searchTwo(data.field,tableInsSix,account_no,performance_date);
                    return false;
                });
                forma.on('submit(reload_six)', function (data) {
                    reload(data.field,tableInsSix,account_no,performance_date);
                    return false;
                });
                tableInsSeven = tableTwo.render({
                    elem: '#Department_RewardRebateEcn'
                    , url: "/sale/results/DepartmentewardCommon"
                    , method: 'post'
                    , where: {
                        start_time: performance_date + " 00:00:00",
                        account_no: account_no,
                    }
                    , cols: [[
                        {field: 'source_account_no', title: '{{  "销售账号" }}',align:'center'}
                        ,{field: 'source_account_full_name', title: '{{  "销售姓名"}}', align:'center'}
                        ,{field: 'source_account_type', title: '{{  "账户类型"}}',align:'center', templet:function (d) {
                                return source_account_type[d.source_account_type] || '';
                            }}
                        ,{field: 'income', title: '{{  "销售收益（USD）"}}',align:'center', templet:function (d){
                                return d.income / 100;
                            }}
                        ,{field: 'rate', title: '{{   "提成比例"}}', align:'center', templet:function (d){
                                return d.rate / 10000 + "%";
                            }}
                        ,{field: 'amount', title: '{{  "提成金额(USD)"}}',align:'center',templet:function (d){
                                return d.amount / 100;
                            }}
                    ]]
                    , page: true
                    , response: {
                        statusName: 'status' //数据状态的字段名称，默认：code
                        , statusCode: 200 //成功的状态码，默认：0
                        , msgName: 'msg' //状态信息的字段名称，默认：msg
                        , countName: 'count' //数据总数的字段名称，默认：count
                        , dataName: 'datas' //数据列表的字段名称，默认：data
                    }
                });
                //监听搜索按钮
                var formb = layui.form;
                formb.on('submit(department_enc_search_btn)', function (data) {
                    search(data.field,tableInsSeven,account_no,performance_date);
                    return false;
                });
                formb.on('submit(reload_seven)', function (data) {
                    reload(data.field,tableInsSeven,account_no,performance_date);
                    return false;
                });
            });
        }
        function search(search_form_data,obj,id,time) {

            var start = search_form_data.start_time;                                        //开始时间
            var end = search_form_data.end_time;                                            //结束时间
            var source_account_no = search_form_data.source_account_no || search_form_data.account_no;                     //客户账号
            var source_account_full_name = search_form_data.source_account_full_name || search_form_data.account_full_name|| search_form_data.account_name;       //客户姓名
            var mt4_order_no = search_form_data.mt4_order_no;                               //订单号
            var account_full_no = search_form_data.account_full_no;                         //代理账号
            var account_full_name = search_form_data.account_full_name;                     //代理姓名
            var id = id;                                                                    // id/客户id
            var time = time + " 00:00:00";                                                  //默认时间

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

            obj.reload({
                where: { //设定异步数据接口的额外参数，任意设
                    start_time: start
                    , end_time: end
                    , source_account_no: source_account_no
                    , source_account_full_name: source_account_full_name
                    , mt4_order_no: mt4_order_no
                    , account_full_no: account_full_no
                    , account_full_name: account_full_name
                    , _id: id
                    , _start_time: time
                }
                , page: {
                    curr: 1 //重新从第 1 页开始
                }
            });
        }


        /*
        *
        *
        *
        * */

        function searchTwo(search_form_data,obj,id,time) {

            var start = search_form_data.start_time;                                        //开始时间
            var end = search_form_data.end_time;                                            //结束时间
            var source_account_no = search_form_data.source_account_no || search_form_data.account_no;                     //客户账号
            var source_account_full_name = search_form_data.source_account_full_name || search_form_data.account_name;       //客户姓名
            var mt4_order_no = search_form_data.mt4_order_no;                               //订单号
            var account_full_no = search_form_data.account_full_no;                         //代理账号
            var account_full_name = search_form_data.account_full_name;                     //代理姓名
            var id = id;                                                                    // id/客户id
            var time = time + " 00:00:00";                                                  //默认时间

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

            obj.reload({
                where: { //设定异步数据接口的额外参数，任意设
                    start_time: start
                    , end_time: end
                    , source_account_no: source_account_no
                    , source_account_full_name: source_account_full_name
                    , mt4_order_no: mt4_order_no
                    , account_full_no: account_full_no
                    , account_full_name: account_full_name
                    , _id: id
                    , _start_time: time
                }
                , page: {
                    curr: 1 //重新从第 1 页开始
                }
            });
        }




        function reload(search_form_data,obj,id,time ){
            $("input[ type='text' ]").val("");
            var id = id;                                                                    // id/客户id
            var time = time + " 00:00:00";
            obj.reload({
                where:{
                      start_time: ""
                    , end_time: ""
                    , source_account_no: ""
                    , source_account_full_name:""
                    , mt4_order_no: ""
                    , account_full_no: ""
                    , account_full_name: ""
                    , _id: id
                    , _start_time: time
                },
                page:{
                    curr:1
                }
            });
        }
    </script>
{% endblock %}


{% block content %}

    <div class="main_content results_center">
        <div class="main_content_holder">
            <div id="fund">
                <div class="main_head">
                    <div class="main_head_unit">
                        {{ Lang.page_rebate_resulit_title || "业绩列表" }}
                    </div>
                    <div id="search_box">
                        <form class="layui-form" action="">

                            <div class="layui-input-inline">
                                <input class="layui-input" name="start_time" id="start_time" placeholder="{{ '选择查询日期' }}" type="text" value="" >
                            </div>
                            <div class="layui-input-inline">
                                <button class="layui-btn" lay-submit="" lay-filter="search_btn" onclick="return false;">{{ Lang.btn_search || "查询" }}</button>
                                <button type="reset" class="layui-btn layui-btn-primary"  lay-submit="" lay-filter="reload"  onclick="return false;">{{ Lang.btn_reset || "清空" }}</button>
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
                <div id="department_detail">
                </div>
            </div>
        </div>
    </div>
    <!--余额返利-->
    <div id="showDetailRebate" style="display:none">
        <div class="main_page_Info">
            <div class="layui-tab layui-tab-brief" lay-filter="sales_detail">
                <div id="department_showDetailRebate">
                    <div id="rebate_search_box">
                        <form class="layui-form"  action="">
                            <div class="layui-form-item">
                                <div class="layui-inline">
                                    <input type="text" class="account_no layui-input" name="source_account_no"  placeholder="{{ Lang.form_placeholder_customer_account_no || '客户账号' }}" autocomplete="off"  >
                                </div>
                                <div class="layui-inline">
                                    <input type="text" class="account_name layui-input" name="source_account_full_name"  placeholder="{{ Lang.form_placeholder_customer_name || '客户姓名' }}" autocomplete="off" >
                                </div>
                                <div class="layui-inline">
                                    <button class="layui-btn" lay-submit lay-filter="rebate_search_btn" onclick="return false;">{{ Lang.btn_search || "查询" }}</button>
                                    <button type="reset" class="layui-btn layui-btn-primary"  lay-submit="" lay-filter="reload_two"  onclick="return false;">{{ Lang.btn_reset || "清空" }}</button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>

            </div>
        </div>
    </div>
    <!--交易返佣-->
    <div id="showDetailCommission" style="display:none">
        <div class="main_page_Info">
            <div class="layui-tab layui-tab-brief" lay-filter="sales_detail">
                <div id="department_showDetailCommission">
                    <div id="commission_search_box">
                        <form class="layui-form"  action="">
                            <div class="layui-form-item">
                                <div class="layui-inline">
                                    <input type="text" class="mt4_order_no layui-input" name="mt4_order_no"  placeholder="{{ '订单编号' }}" autocomplete="off">
                                </div>
                                <div class="layui-inline">
                                    <input type="text" class="account_no layui-input" name="source_account_no"  placeholder="{{  '客户账号' }}" autocomplete="off">
                                </div>
                                <div class="layui-inline">
                                    <input type="text" class="account_name layui-input" name="source_account_full_name"  placeholder="{{ '客户姓名' }}" autocomplete="off">
                                </div>
                                <div class="layui-inline">
                                    <button class="layui-btn" lay-submit lay-filter="commission_search_btn" onclick="return false;">{{ Lang.btn_search || "查询" }}</button>
                                    <button type="reset" class="layui-btn layui-btn-primary"  lay-submit="" lay-filter="reload_three"  onclick="return false;">{{ Lang.btn_reset || "清空" }}</button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!--销售提成-->
    <div id="showDetailCommonRebate" style="display:none">
        <div class="layui-tab layui-tab-card">
            <ul class="layui-tab-title">
                <li class="layui-this">非直客ECN账户交易提成</li>
                <li>
                    非直客BAPPEBTI账户提成
                </li>
            </ul>
            <div class="layui-tab-content">
                <div class="layui-tab-item layui-show">
                    <div id="CommonRebate_RewardRebateCommon">
                        <div id="commonrebate_common_search_box">
                            <form class="layui-form"  action="">
                                <div class="layui-form-item">
                                    <div class="layui-inline">
                                        <input type="text" class="mt4_order_no layui-input" name="mt4_order_no"  placeholder="{{ '订单编号' }}" autocomplete="off">
                                    </div>
                                    <div class="layui-inline">
                                        <input type="text" class="account_no layui-input" name="account_no"  placeholder="{{  '客户账号' }}" autocomplete="off">
                                    </div>
                                    <div class="layui-inline">
                                        <input type="text" class="account_name layui-input" name="account_name"  placeholder="{{ '客户姓名' }}" autocomplete="off">
                                    </div>
                                    <div class="layui-inline">
                                        <input type="text" class="account_full_no layui-input" name="account_full_no"  placeholder="{{  '代理账号' }}" autocomplete="off">
                                    </div>
                                    <div class="layui-inline">
                                        <input type="text" class="account_full_name layui-input" name="account_full_name"  placeholder="{{ '代理姓名' }}" autocomplete="off">
                                    </div>
                                    <div class="layui-inline">
                                        <button class="layui-btn" lay-submit lay-filter="commonrebate_common_search_btn" onclick="return false;">{{ Lang.btn_search || "查询" }}</button>
                                        <button type="reset" class="layui-btn layui-btn-primary"  lay-submit="" lay-filter="reload_four"  onclick="return false;">{{ Lang.btn_reset || "清空" }}</button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
                <div class="layui-tab-item">
                    <div id="CommonRebate_RewardRebateEcn">
                        <div id="commonrebate_ecn_search_box">
                            <form class="layui-form"  action="">
                                <div class="layui-form-item">
                                    <div class="layui-inline">
                                        <input type="text" class="account_full_no layui-input" name="account_full_no"  placeholder="{{  '代理账号' }}" autocomplete="off">
                                    </div>
                                    <div class="layui-inline">
                                        <input type="text" class="account_full_name layui-input" name="account_full_name"  placeholder="{{ '代理姓名' }}" autocomplete="off">
                                    </div>
                                    <div class="layui-inline">
                                        <button class="layui-btn" lay-submit lay-filter="commonrebate_ecn_search_btn" onclick="return false;">{{ Lang.btn_search || "查询" }}</button>
                                        <button type="reset" class="layui-btn layui-btn-primary"  lay-submit="" lay-filter="reload_five"  onclick="return false;">{{ Lang.btn_reset || "清空" }}</button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!--总监提成-->
    <div id="showDetailDepartmentRebate" style="display:none">
        <div class="layui-tab layui-tab-card">
            <ul class="layui-tab-title">
                <li class="layui-this">
                    ECN账户交易提成
                </li>
                <li>
                    BAPPEBTI账户提成
                </li>
            </ul>
            <div class="layui-tab-content">
                <div class="layui-tab-item layui-show">
                    <div id="Department_RewardRebateCommon">
                        <div id="department_common_search_box">
                            <form class="layui-form"  action="">
                                <div class="layui-form-item">
                                    <div class="layui-inline">
                                        <input type="text" class="mt4_order_no layui-input" name="mt4_order_no"  placeholder="{{ '订单编号' }}" autocomplete="off">
                                    </div>
                                    <div class="layui-inline">
                                        <input type="text" class="account_no layui-input" name="account_no"  placeholder="{{  '客户账号' }}" autocomplete="off">
                                    </div>
                                    <div class="layui-inline">
                                        <input type="text" class="account_name layui-input" name="account_name"  placeholder="{{ '客户姓名' }}" autocomplete="off">
                                    </div>
                                    <div class="layui-inline">
                                        <input type="text" class="account_full_no layui-input" name="account_full_no"  placeholder="{{  '代理账号' }}" autocomplete="off">
                                    </div>
                                    <div class="layui-inline">
                                        <input type="text" class="account_full_name layui-input" name="account_full_name"  placeholder="{{ '代理姓名' }}" autocomplete="off">
                                    </div>
                                    <div class="layui-inline">
                                        <button class="layui-btn" lay-submit lay-filter="department_common_search_btn" onclick="return false;">{{ Lang.btn_search || "查询" }}</button>
                                        <button type="reset" class="layui-btn layui-btn-primary"  lay-submit="" lay-filter="reload_six"  onclick="return false;">{{ Lang.btn_reset || "清空" }}</button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
                <div class="layui-tab-item">
                    <div id="Department_RewardRebateEcn">
                        <div id="department_ecn_search_box">
                            <form class="layui-form"  action="">
                                <div class="layui-form-item">
                                    <div class="layui-inline">
                                        <input type="text" class="account_full_no layui-input" name="account_full_no"  placeholder="{{  '销售账号' }}" autocomplete="off">
                                    </div>
                                    <div class="layui-inline">
                                        <input type="text" class="account_full_name layui-input" name="account_full_name"  placeholder="{{ ' 销售姓名' }}" autocomplete="off">
                                    </div>
                                    <div class="layui-inline">
                                        <button class="layui-btn" lay-submit lay-filter="department_enc_search_btn" onclick="return false;">{{ Lang.btn_search || "查询" }}</button>
                                        <button type="reset" class="layui-btn layui-btn-primary"  lay-submit="" lay-filter="reload_seven"  onclick="return false;">{{ Lang.btn_reset || "清空" }}</button>
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
