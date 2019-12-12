{% extends '../../common/layouts/layout.tpl' %}
{% block content %}

    <div class="main_content">
        <div class="main_content_holder">
            <div id="fund">
                <div class="main_head">
                    <div class="main_head_unit">
                        {{ Lang.page_ib_title || "代理列表" }}
                    </div>
                    <div id="search_box">

                        <form class="layui-form" action="">
                            <div class="layui-form-item">
                                <div class="layui-inline">
                                    <input type="text" name="customer_name"  placeholder="{{ Lang.form_placeholder_name || "姓名" }}" autocomplete="off" class="layui-input">
                                </div>

                                <div class="layui-inline">
                                    <input type="text" name="email" placeholder="{{ Lang.form_placeholder_login_email || "邮箱" }}" autocomplete="off" class="layui-input">
                                </div>

                                <div class="layui-inline">
                                    <input type="text" name="account_no"  placeholder="{{ Lang.form_placeholder_account_no || "账号" }}" autocomplete="off" class="layui-input">
                                </div>


                                <div class="layui-inline">
                                    <button class="layui-btn" lay-submit lay-filter="search_btn">{{ Lang.btn_search || "查询" }}</button>
                                    <button type="reset" class="layui-btn layui-btn-primary" onclick="reload()">{{ Lang.btn_reset || "清空" }}</button>
                                </div>

                            </div>
                        </form>

                    </div>

                </div>
                <div class="main_page_Info">
                    <table  class="layui-hide" id="agent_list" lay-filter="dataTable"></table>
                    <div class="page">

                    </div>
                </div>
            </div>
        </div>
    </div>
{% endblock %}
{% block js_assets %}
    <script>
        function showDetail(ibid) {
            window.location.href ="/sale/ib/info/?ibid="+ ibid;
        }
        var tableIns;
        layui.use(['laydate','table'], function(){
            var laydate = layui.laydate;

            //执行一个laydate实例
            laydate.render({
                elem: '#start_time' //指定元素
            });
            laydate.render({
                elem: '#end_time' //指定元素
            });

            var table = layui.table;
            //第一个实例
            tableIns= table.render({
                elem: '#agent_list'
                ,url: '/sale/ib/list' //数据接口
                ,page: true //开启分页
                ,method:'post'
                ,cols: [[ //表头

                    {field: 'gmt_create', title: '{{Lang.table_gmt_create || "注册时间" }}',sort:true, align:'center',fixed: 'left',},
                    {field: 'customer_name', title: '{{ Lang.table_customer_name || "姓名"}}', align:'center',width:150,templet:function (row) {
                        return '<a onclick="showDetail(\''+row.id+'\')"  href="javascript:;">' + row.customer_name + '</a>'
                    } }
                    ,{field: 'mobile', title: '{{ Lang.table_mobile || "手机号码"}}', align:'center'}
                    ,{field: 'email', title: '{{ Lang.table_email || "电子邮箱"}}',align:'center'}
                    ,{field: 'balance', title: '{{ Lang.table_balance || "账户余额"}}',align:'center', templet: function (d) {
                        if(d.balance) {
                            return d.balance / 100;
                        }else{
                            return 0;
                        }
                        }}
                    ,{field: 'total_withdraw_amount', title: '{{ Lang.table_sum_withdraw || "总出金"}}', align:'center',templet:function(d){
                            if(d.total_withdraw_amount){
                                return d.total_withdraw_amount / 100;
                            }else{
                                return 0;
                            }
                        }}
                    ,{field: 'total_customer', title: '{{ Lang.table_total_customer || "代理客户总数"}}',align:'center'}
                    ,{field: 'total_customer_balance', title: '{{ Lang.table_total_customer_balance || "代理客户总账户余额"}}',align:'center',templet:function(d){
                            if(d.total_customer_balance){
                                return d.total_customer_balance / 100;
                            }else{
                                return 0;
                            }
                        }}
                    ,{field: 'sum_trade_volume', title: '{{Lang.table_sum_trade_volume_ib || "代理客户总交易量" }}', align:'center',templet:function(d){
                            if(d.sum_trade_volume){
                                return d.sum_trade_volume / 100;
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

            //监听搜索按钮
            var form = layui.form;
            form.on('submit(search_btn)', function (data) {
                search(data.field);
                return false;
            });

            table.on('sort(dataTable)', function(obj){ //注：tool是工具条事件名，test是table原始容器的属性 lay-filter="对应的值"
                //尽管我们的 table 自带排序功能，但并没有请求服务端。
                //有些时候，你可能需要根据当前排序的字段，重新向服务端发送请求，从而实现服务端排序，如：
                table.reload('agent_list', {
                    initSort: obj //记录初始排序，如果不设的话，将无法标记表头的排序状态。 layui 2.1.1 新增参数
                    ,where: { //请求参数（注意：这里面的参数可任意定义，并非下面固定的格式）
                        field: obj.field    //当前排序的字段名
                        ,order: obj.type,    //当前排序类型：desc（降序）、asc（升序）、null（空对象，默认排序）
                        customer_name: $('input[name="customer_name"]').val(),
                        email: $('input[name="email"]').val(),
                        account_no: $('input[name="account_no"]').val()
                    }
                });
            });

            function search(search_form_data) {
                tableIns.reload({
                    where: { //设定异步数据接口的额外参数，任意设
                        customer_name: search_form_data.customer_name,
                        email: search_form_data.email,
                        account_no: search_form_data.account_no
                    }
                    , page: {
                        curr: 1 //重新从第 1 页开始
                    }
                });
            }

        });
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