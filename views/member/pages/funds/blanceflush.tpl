
{% extends '../../common/layouts/layout.tpl' %}

{% block css_assets %}

    {# 引入css #}
{% endblock %}



{% block js_assets %}
    <script>
        //订单状态
        var stateMap = new Object();
        {% for at in Lang.select.member.funds.order_state %}
        stateMap[{{ at.value }}] = "{{ at.label }}";
        {% endfor %}

        //查看详情
        function showDetail(id) {
            $.ajax({
                url: '/member/funds/balance_flush/info',
                async: true,
                data: {"id": id},
                type: 'post',
                dataType: 'json',
                contentType: "application/x-www-form-urlencoded;charset=utf-8",
                success: function (data) {
                    if (data.status == 200) {
                        var bf = JSON.parse(data.datas);
                        if (bf) {
                            $("#order_no").html(bf.order_no);
                            $("#account_no").html(bf.account_no);
                            $("#amount").html(bf.amount / 100 || 0);
                            $("#order_status").html(stateMap[bf.order_status] || '处理中');
                            $("#gmt_create").html(bf.gmt_create);
                            $("#gmt_modified").html(bf.gmt_modified);
                        }
                    }
                    layer.open({
                        type: 1,
                        title: '{{ Lang.page_funds_blanceflush_info_title || "余额清零详情" }}',
                        area: ['500px', 'auto'],
                        content: $('#detail')
                    });
                }
            });
        }

        var tableIns;
        layui.use(['form', 'table'], function () {
            var table = layui.table;
            tableIns = table.render({
                elem: "#bf",
                url: '/member/funds/balance_flush/list',
                method: 'post',
                page: true,
                cols: [[
                    {
                        field: 'order_no', title: '{{ Lang.table_order_no || "订单编号" }}', width: 300, align: 'center', templet: function (d) {
                            return '<a onclick="showDetail(\'' + d.id + '\')" href="javascript:;">' + d.order_no + '</a>';
                        }
                    },
                    {field: 'account_no', title: '{{ Lang.table_source_account_no || "账号" }}', align: 'center'},
                    {
                        field: 'amount', title: '{{ Lang.table_difference || "金额(USD)" }}', sort: true, align: 'center', templet: function (d) {
                            return d.amount / 100 || 0;
                        }
                    },
                    {field: 'gmt_create', title: '{{ Lang.table_gmt_create_1 || "创建时间" }}', sort: true, align: 'center'},
                    {
                        field: 'order_status', title: '{{ Lang.table_state || "订单状态" }}', align: 'center', templet: function (d) {
                            return (stateMap[d.order_status] || '{{ Lang.table_content_state || "处理中" }}');
                        }
                    },
                ]],
                response: {
                    statusName: 'status',
                    statusCode: 200,
                    msgName: 'msg',
                    countName: 'count',
                    dataName: 'datas'
                }
            });
            table.on('sort(dataTable)', function(obj){ //注：tool是工具条事件名，test是table原始容器的属性 lay-filter="对应的值"
                //尽管我们的 table 自带排序功能，但并没有请求服务端。
                //有些时候，你可能需要根据当前排序的字段，重新向服务端发送请求，从而实现服务端排序，如：
                table.reload('bf', {
                    initSort: obj //记录初始排序，如果不设的话，将无法标记表头的排序状态。 layui 2.1.1 新增参数
                    ,where: { //请求参数（注意：这里面的参数可任意定义，并非下面固定的格式）
                        field: obj.field    //当前排序的字段名
                        ,order: obj.type,    //当前排序类型：desc（降序）、asc（升序）、null（空对象，默认排序）
                        account_no: $('input[name="account_no"]').val(),
                        state: $('input[name="state"]').val()
                    }
                });
            });

            //搜索表单
            var form = layui.form;
            form.on('submit(search_btn)', function (data) {
                search(data.field);
                return false;
            });

            function search(search_form_data) {
                tableIns.reload({
                    where: {
                        account_no: search_form_data.account_no,
                        state: search_form_data.state
                    },
                    page: {
                        curr: 1
                    }
                });
            }
        });
    </script>
    {# 引入js #}
{% endblock %}



{% block content %}
    <div class="main_content">
        <div class="main_content_holder">
            <div id="fund">
                <div class="main_head">
                    <div class="main_head_unit">
                        {{ Lang.page_funds_blanceflush_title || "余额清零记录" }}
                    </div>
                    <div id="search_box">

                        <form class="layui-form"  action="">

                            {#<label class="input-title">{{ Lang.table_mt4_account || "MT4账号" }}：</label>#}
                            <div class="layui-input-inline">
                                <select name="account_no" class="layui-input">
                                    <option value="">{{ Lang.form_placeholder_account_no || "账号" }}</option>
                                    {#{% for ac in account %}
                                        <option value="{{ ac.account_no }}">{{ ac.account_no }}-{{ ac.account_type | accountType }}</option>
                                    {% endfor %}#}
                                </select>
                            </div>

                           {# <label class="input-title">状态：</label>#}
                            <div class="layui-input-inline">
                                <select name="state">
                                    <option value="">{{ Lang.table_state || "订单状态" }}</option>
                                    {% for at in Lang.select.member.funds.balance_flush_order_state %}
                                        <option value="{{ at.value }}">{{ at.label }}</option>
                                    {% endfor %}
                                </select>
                            </div>
                            <div class="layui-input-inline">
                                <button class="layui-btn" lay-submit="" lay-filter="search_btn" onclick="javascript:return false;">{{ Lang.btn_search || "查询" }}</button>
                                <button type="reset" class="layui-btn layui-btn-primary">{{ Lang.btn_reset || "清空" }}</button>
                            </div>

                        </form>

                    </div>

                </div>

                <div class="main_page_Info">
                    <table class="layui-hide" id="bf" lay-filter="dataTable"></table>
                    <div class="page"></div>
                </div>
            </div>
        </div>
    </div>
    <div id="detail" style="display:none">
        <form class="layui-form show-detail" action="">
            <div class="d-item">
                <label>{{ Lang.form_label_order_no || "订单编号" }}:</label>
                <span id="order_no"></span>
            </div>

            <div class="d-item">
                <label>{{ Lang.form_placeholder_account_no || "账号" }}:</label>
                <span id="account_no"></span>
            </div>

            <div class="d-item">
                <label>{{ Lang.form_label_application_amount || "申请金额(USD)" }}:</label>
                <span id="amount">50</span>
            </div>

            <div class="d-item">
                <label>{{ Lang.table_state || "订单状态" }}:</label>
                <span id="order_status"></span>
            </div>

            <div class="d-item">
                <label>{{ Lang.form_text_gmt_create || "创建时间" }}:</label>
                <span id="gmt_create"></span>
            </div>

            <div class="d-item">
                <label>{{ Lang.form_text_gmt_modified || "更新时间" }}:</label>
                <span id="gmt_modified"></span>
            </div>
        </form>
    </div>
{% endblock %}
