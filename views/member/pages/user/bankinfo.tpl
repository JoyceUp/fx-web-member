fundsrecord.tpl
{% extends '../../common/layouts/layout.tpl' %}

{% block css_assets %}
    {# 引入css #}
{% endblock %}

{% set myselect =  Lang.select.member.customer %}


{% block js_assets %}
    {# 引入js #}
{% endblock %}



{% block content %}
    <div class="zhezhao" style="display: none;"></div>
    <div class="main_content">
        <div class="main_content_holder">
            <div id="fund">
                <div class="main_head">
                    <div class="main_head_unit">
                        {{ Lang.page_user_bankinfo_title || "银行信息" }}
                    </div>
                    <div class="main_head_text required"></div>
                </div>
                <div class="main_page_Info">
                    <div class="form">
                        <div class="form_input">

                            <div class="fund-box">
                                <div class="con-fund con-show clearfix my-bank-card-list">
                                    {% for card in datas.items %}
                                        <div class="card-b rad4 brick my-bank-card" id="card_{{ card.id }}">
                                            <h1 class="clearfix rad1-2">
                                                {% if banks_option.cn[card.bank_name] %}
                                                    <span><img src="{{ banks_option.cn[card.bank_name].logo }}"></span>
                                                {% else %}
                                                  {#  <span><img src="{{ myselect.banks.other.logo }}"></span>#}
                                                {% endif %}
                                                <span>{{ card.bank_name }}</span>
                                                <a href="javascript:void(0);" class="car-btn rad2 del delete" onclick="javascript:delWindowOpen('{{ card.id }}');">{{ Lang.btn_delete || "删除" }}</a>
                                                <a href="javascript:void(0);" class="car-btn rad2 revise btn1" onclick="javascript:showCardInfo('{{ card.id }}');">{{ Lang.btn_update || "修改" }}</a>
                                            </h1>
                                            <div class="info-c">
                                                <p><strong>{{ Lang.form_label_card_no || "银行卡号" }}</strong>{{ card.card_no | hideBankCardNo }}</p>
                                                <p><strong>{{ Lang.form_label_bank_account || "开户银行" }}</strong>{{ card.branch_name }}</p>
                                            </div>
                                        </div>
                                    {% endfor %}

                                    <div class="card-c rad4 btn1 card-b" onclick="javascript:showCardInfo();"></div>


                                </div>
                            </div>

                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div id="cardInfo" style="display:none">
        {% include "./bankinfo_card.tpl" %}
    </div>
    {# 内容 #}

    <script type="text/javascript">

        var bank_logo = JSON.parse(jQuery.parseHTML("{{ banks }}")[0].data);

        //显示银行卡信息
        function showCardInfo(id) {
            if (null == id || "" == id || undefined == id) {
                var title = "{{ Lang.page_user_bankinfo_add_title || "添加银行卡" }}";
                emptyDialogData();
                showCardBox(title);

            } else {
                $.when(findCardData(id)).done(function (data) {
                    var title = "{{ Lang.page_user_bankinfo_up_title || "修改银行卡" }}";
                    showCardBox(title);

                });
            }
        }

        //
        function showCardBox(title) {
            layer.open({
                type: 1,
                title: title,
                area: ['1000px', 'auto'], //宽高
                content: $("#cardInfo"),
                success: function () {

                    initUpload()
                }
            });
        }

        //获取数据
        function findCardData(id) {

            var data = {"id": id};

            var defer = $.Deferred();
            jQuery.ajax({
                url: '/member/customer/bankinfo/info',
                timeout: 2 * 60 * 1000,
                async: true,
                data: JSON.stringify(data),
                type: 'POST',
                dataType: 'JSON',
                contentType: "application/json; charset=\"utf-8\"",
                success: function (result, status) {
                    initDialogData(JSON.parse(result.datas));
                    defer.resolve(result);
                },
                error: function (result, status) {
                    defer.resolve();
                }
            });
            return defer.promise();
        }


        //删除银行卡
        function delWindowOpen(id) {
            if (jQuery(".my-bank-card").length < 2) {
                layer.msg("{{ Lang.msg_keep_a_bank_card || "请至少保留一张银行卡" }}", {
                    icon: 2
                });
                return;
            }
            layer.confirm('{{ Lang.open_confirm_delete_bank || "确定要删除该银行卡" }}？', {
                btn: ['{{ Lang.btn_yes || "是" }}', '{{ Lang.btn_no || "否" }}'] //按钮
            }, function () {
                //是

                var data = {"id": id};
                jQuery.ajax({
                    url: '/member/customer/bankinfo/delete',
                    timeout: 2 * 60 * 1000,
                    async: true,
                    data: JSON.stringify(data),
                    type: 'POST',
                    dataType: 'JSON',
                    contentType: "application/json; charset=\"utf-8\"",
                    success: function (result, status) {
                        if (result.status === 200) {
                            layer.msg("{{ Lang.msg_delete_success || "删除成功" }}", {
                                icon: 1
                            });

                            jQuery("#card_" + id).remove();
                        }
                        else {
                            layer.msg(result.msg, {
                                icon: 0
                            });
                        }
                        return false;
                    },
                    error: function (result, status) {
                        layer.msg(result.msg, {
                            icon: 2
                        });
                    }
                });
            }, function () {
                //否
            });

        }

        //编辑页面银行卡数据
        function modifyCardList(data) {
            var logo = bank_logo.other.logo;
            if (bank_logo.cn[data.bank_name]) {
                logo = bank_logo.cn[data.bank_name].logo;
            }else{
                logo=""
            }
            var innerHtml = "";
            innerHtml += "<h1 class=\"clearfix rad1-2\">";
            if(logo !=""){
                innerHtml += "<span><img src=\"" + logo + "\"></span>";
            }
            innerHtml += "<span>" + data.bank_name + "</span>";
            innerHtml += "<a href=\"javascript:void(0);\" class=\"car-btn rad2 del delete\" onclick=\"javascript:delWindowOpen('" + data.id + "');\">{{ Lang.btn_delete || "删除" }}</a>";
            innerHtml += "<a href=\"javascript:void(0);\" class=\"car-btn rad2 revise btn1\" onclick=\"javascript:showCardInfo('" + data.id + "');\">{{ Lang.btn_update || "修改" }}</a>";
            innerHtml += "</h1>";
            innerHtml += "<div class=\"info-c\">";
            innerHtml += "<p><strong>{{ Lang.form_label_card_no || "银行卡号"}}</strong>" + data.card_no + "</p>";
            innerHtml += "<p><strong>{{ Lang.form_label_bank_account || "开户银行" }}</strong>" + data.branch_name + "</p>";
            innerHtml += "</div>";

            if (jQuery("#card_" + data.id).length > 0) {
                jQuery("#card_" + data.id).html(innerHtml);
            }
            else {
                var outerHtml = ("<div class=\"card-b rad4 brick my-bank-card\" id=\"card_" + data.id + "\">");
                outerHtml += innerHtml;
                outerHtml += "</div>";
                jQuery(".my-bank-card-list .card-c").before(outerHtml);
            }
        }
    </script>
{% endblock %}
