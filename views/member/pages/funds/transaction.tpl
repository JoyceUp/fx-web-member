
{% extends '../../common/layouts/layout.tpl' %}

{% block css_assets %}

    {# 引入css #}
{% endblock %}



{% block js_assets %}
<script>
var stateMap = new Object();
{% for at in Lang.select.member.funds.state %}
stateMap[{{ at.value }}] = "{{ at.label }}";
{% endfor %}

var mt4TransferTypeMap = new Object();
{% for at in Lang.select.member.funds.mt4_transfer_type %}
mt4TransferTypeMap[{{ at.value}}] ="{{at.label }}";
{% endfor %}

//详情
function showDetail(id){
    $.ajax({
        url:'/member/funds/transaction/info',
        async: true,
        type:'post',
        dataType:'json',
        data:{"id":id},
        contentType: "application/x-www-form-urlencoded;charset=utf-8",
        success:function(data){
            if(data.status==200){
                var transaction = data.datas;
                if(transaction){
                    $("#id").html(transaction.id);
                    $("#gmt_create").html(transaction.gmt_create);
                    /*if(deposit.state == 12){//处理中，增加取消按钮
                        $("#cancelBut").html('');

                    }*/
                }
                layer.open({
                    type:1,
                    title:'{{ Lang.page_funds_transaction_info_title || "交易记录详情" }}',
                    area:['500px', 'auto'],
                    content:$('#detail')
                });
            }
        }
    });
}

    //列表
    var tableIns;
    layui.use(['table','form','laydate'],function(){
        //日期
        var laydate = layui.laydate;
        laydate.render({
            elem:'#start_k',
            type:'datetime'
        });
        laydate.render({
            elem:'#end_k',
            type:'datetime'
        });

        laydate.render({
            elem:'#start_p',
            type:'datetime'
        });
        laydate.render({
            elem:'#end_p',
            type:'datetime'
        });
        var table = layui.table;
        tableIns = table.render({
            elem:'#dataTable',
            url:'/member/funds/transaction/list',
            method: 'post',
            page:true,
            cols:[[
                {field:'id',title:'{{ Lang.table_order_no || "订单编号"}}',width:300,sort:true,align:'center'},
                {field:'account_no',title:'{{ Lang.table_mt4_account || "MT4账号"}}',align:'center'},
                {field:'open_time',title:'{{ Lang.table_open_time || "开仓时间"}}',sort:true,align:'center'},
                {field:'type',title:'{{ Lang.table_type || "交易类型"}}',align:'center',templat:function(){
                    return mt4TransferTypeMap[d.type];
                    }},
                {field:'symbol',title:'{{Lang.table_trading_symbol || "交易品种" }}',align:'center'},
                {field:'volume',title:'{{ Lang.table_trading_volume || "交易量"}}',sort:true,align:'center'},
                {field:'open_price',title:'{{ Lang.table_open_price || "开仓价格"}}',sort:true,align:'center'},
                {field:'close_price',title:'{{ Lang.table_close_price || "平仓价格"}}',sort:true,align:'center'},
                {field:'',title:'{{ Lang.table_close_time || "平仓时间"}}',sort:true,align:'center'},
                {field:'sl',title:'S/L',sort:true,align:'center'},
                {field:'tp',title:'T/P',sort:true,align:'center'},
                {field:'fee',title:'{{ Lang.table_fee || "手续费(USD)"}}',sort:true,align:'center'},
                {field:'swaps',title:'{{ Lang.table_swaps || "隔夜利息"}}',sort:true,align:'center'},
                {field:'profit',title:'{{ Lang.table_profit || "交易盈亏"}}',sort:true,align:'center'},
                {field:'state',title:'{{ Lang.table_account_state_1 || "状态"}}',sort:true,align:'center',templet:function(d){
                        return stateMap[d.state];
                    }}
            ]],
            response:{
                statusName:'status',
                statusCode :200,
                msgName:'msg',
                countName:'count',
                dataName:'datas'
            }
        });
        table.on('sort(dataTable)', function(obj){ //注：tool是工具条事件名，test是table原始容器的属性 lay-filter="对应的值"
            //尽管我们的 table 自带排序功能，但并没有请求服务端。
            //有些时候，你可能需要根据当前排序的字段，重新向服务端发送请求，从而实现服务端排序，如：
            table.reload('dataTable', {
                initSort: obj //记录初始排序，如果不设的话，将无法标记表头的排序状态。 layui 2.1.1 新增参数
                ,where: { //请求参数（注意：这里面的参数可任意定义，并非下面固定的格式）
                    field: obj.field    //当前排序的字段名
                    ,order: obj.type,    //当前排序类型：desc（降序）、asc（升序）、null（空对象，默认排序）
                    account_no_to: $('input[name="account_no_to"]').val(),
                    account_no_from: $('input[name="account_no_from"]').val(),
                    state: $('input[name="state"]').val(),
                    start_time : $('input[name="start_time"]').val(),
                    end_time : $('input[name="end_time"]').val()
                }
            });
        });

        //搜索表单
        var form = layui.form;
        form.on('submit(search_btn)',function(data){
            if(data.field.start_time && data.field.end_time){
                if(new Date(data.field.start_time).getTime() > new Date(data.field.end_time).getTime()){
                    layer.alert("{{ Lang.alert_start_time_more_than_the_end_time || "开始时间 不能大于 结束时间" }}", {
                        title: '{{ Lang.page_msg_h3 || "提示：" }}'
                    });
                    return false;
                }
            }
            search(data.field);
            return false;
        });

        function search(search_form_data){
            tableIns.reload({
                where:{
                    account_no_to:search_form_data.account_no_to,
                    account_no_from:search_form_data.account_no_from,
                    state:search_form_data.state,
                    start_time :search_form_data.start_time,
                    end_time :search_form_data.end_time
                },
                page:{
                    curr:1
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
                        {{ Lang.form_text_transaction_record || " 交易记录 " }}
                    </div>
                    <div id="search_box">

                        <form class="layui-form"  action="">

                          {#  <label class="input-title">{{ Lang.table_mt4_account || "MT4账号" }}：</label>#}
                            <div class="layui-input-inline">
                                <input type="text" name="account_no" placeholder="{{ Lang.table_mt4_account || "MT4账号" }}" autocomplete="off"
                                       class="layui-input">
                            </div>

                            <div class="layui-input-inline">
                                <input class="layui-input" id="start_k" name="start_k" placeholder="{{ Lang.table_open_time || "开仓时间" }}" type="text" value="" >
                            </div>
                            <div class="layui-input-inline">
                                -
                            </div>
                            <div class="layui-input-inline">
                                <input class="layui-input" id="end_k" name="end_k" placeholder="{{ Lang.table_open_time || "开仓时间" }}" type="text" value="">
                            </div>


                            <div class="layui-input-inline">
                                <input class="layui-input" id="start_p" name="start_p" placeholder="{{ Lang.table_close_time || "平仓时间" }}" type="text" value="" >
                            </div>
                            <div class="layui-input-inline">
                                -
                            </div>
                            <div class="layui-input-inline">
                                <input class="layui-input" id="end_p" name="end_p" placeholder="{{ Lang.table_close_time || "平仓时间" }}" type="text" value="">
                            </div>


                            <div class="layui-input-inline">
                                <select name="state">
                                    <option value="">{{ Lang.table_trading_symbol || "交易品种" }}</option>
                                    {% for at in select.state %}
                                        <option value="{{ at.value }}">{{ at.label }}</option>
                                    {% endfor %}
                                </select>
                            </div>
                            <div class="layui-input-inline">
                                <select name="state">
                                    <option value="">{{ Lang.table_type || "交易类型" }}</option>
                                    {% for at in Lang.select.member.funds.mt4_transfer_type %}
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
                    <table class="layui-hide" id="dataTable" lay-filter="dataTable"></table>
                    <div class="page"></div>
                </div>
            </div>
        </div>
    </div>

{% endblock %}
