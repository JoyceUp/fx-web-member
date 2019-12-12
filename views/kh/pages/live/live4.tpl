<div class="register">
    <div class="succ succ_page">
        <div class="succ-icon">
            <img src="/assets/kh/images/succ-icon.png">
        </div>
        <h4>
            <span>{{ Lang.page_register_step4_title4_1 || "恭喜！注册成功！" }}</span><br/>
            {{ Lang.page_register_step4_tips1 || "MT4账号：" }}<em id="res_acc"></em>{{ Lang.page_register_step4_tips2 || "，交易密码已发送到您的邮箱！" }}
        </h4>
        <div id="resmtid"><em id="jumpTo">10</em>{{ Lang.page_register_skip_tips || "，秒后自动跳转" }}</div>
        <p></p>
        <p></p>
    </div>
    <div class="succ fail_page none">
        <h4>{{ Lang.page_register_step4_tips3 || "抱歉！注册失败！失败原因为 " }}<em id="res_err_acc"></em></h4>
    </div>
</div>

{% block js_assets %}
    {#/member/account/mt#}
    <script>
        function countDown(secs, surl) {
            var jumpTo = document.getElementById('jumpTo');
            jumpTo.innerHTML = secs;
            if (--secs > 0) {
                setTimeout("countDown(" + secs + ",'" + surl + "')", 1000);
            } else {
                location.href = surl;
            }
        }
    </script>
{% endblock %}