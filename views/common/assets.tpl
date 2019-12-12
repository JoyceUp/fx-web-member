<meta name="renderer" content="webkit|ie-comp|ie-stand">
<script type="text/javascript" src="/assets/vendors/jquery-ui/jquery-1.8.3.js"></script>
<script type="text/javascript" src="/assets/vendors/layui/layui.js"></script>

<link rel="stylesheet" href="/assets/member/styles/personal.css?v=1" >
<link rel="stylesheet" href="/assets/vendors/layui/css/layui.css" >

<link rel="stylesheet" href="/assets/member/styles/zh/css/index.css" >
{% if Lang.lang=="en" %}
<link rel="stylesheet" href="/assets/member/styles/rewrite_en.css" >
{% else %}
<link rel="stylesheet" href="/assets/member/styles/rewrite.css" >
{% endif %}
<script type="text/javascript" src="/assets/member/scripts/utils/cookieUtils.js"></script>

<link href="http://at.alicdn.com/t/font_540585_hes1nqws8wefjemi.css" rel="stylesheet" type="text/css">

<script type="text/javascript" src="/assets/member/scripts/utils/validate.js"></script>
<script type="text/javascript" src="/assets/member/scripts/utils/utils.js"></script>
<script type="text/javascript" src="/assets/member/scripts/utils/commonUtils.js"></script>


<!--[if (gte IE 8)&(lte IE 9)]>
<link href="/assets/member/styles/ie/personal_ie9.css" rel="stylesheet">
<link href="/assets/member/styles/ie/modifyPwd_ie9.css" rel="stylesheet">
<![endif]-->
<!--[if IE 9]>
<script type="text/javascript" src="/assets/member/scripts/ie/jqplaceHolder.js"></script>
<![endif]-->
<!--[if IE 8]>
<script type="text/javascript" src="/assets/member/scripts/ie/nwmatcher.js"></script>
<script type="text/javascript" src="/assets/member/scripts/ie/selectivizr-min.js"></script>
<script type="text/javascript" src="/assets/member/scripts/ie/jqplaceHolder.js"></script>
<![endif]-->

<!--[if lt IE 9]>
<script src="https://cdn.staticfile.org/html5shiv/r29/html5.min.js"></script>
<script src="https://cdn.staticfile.org/respond.js/1.4.2/respond.min.js"></script>
<![endif]-->

<script>
    var ua = navigator.userAgent.toLowerCase();
    if (ua.match(/msie/) != null || ua.match(/trident/) != null) {
        var browserVersion = ua.match(/msie ([\d.]+)/) != null ? ua.match(/msie ([\d.]+)/)[1] : ua.match(/rv:([\d.]+)/)[1];
        if (browserVersion < 9 ) {
            location.href = "/browser/update"
        }
    }
    var gotourl="/member/login"
    var href=window.location.href
    if(href.indexOf("ib")>-1){
        gotourl="/ib/login"
    }else if(href.indexOf("sale")>-1){
        gotourl="/sale/login"
    }

    $.ajaxSetup({
        dataFilter: function () {

            if(arguments[0].indexOf("status")>-1){
                var result = JSON.parse(arguments[0]);
                if (result.status && result.status == 401) {


                    window.location.href = gotourl;
                }
            }

            return arguments[0];
        }
    });






    //账户类型 id-value
    var accountTypeMap = new Object();
    {% for at in Lang.select.member.account.account_type %}
    accountTypeMap[{{ at.value }}] = "{{ at.label }}";
    {% endfor %}

    $(function () {
        initAccountNo()//统一处理账户下拉框，账号与账号类型拼接展示
        initAccountID()//统一处理账户下拉框，账号与账号类型拼接展示
        initAccountIDType()//入金的账号下拉框
        initAccountType()
    })

    initAccountNo=function(){//值是账号的下拉框

        // 账户下拉框
        {#var accountHtml = '  <option value="">{{ Lang.form_placeholder_account_no || "账号" }}</option>';#}
        var accountHtml = '';
        {% for ac in account %}
        accountHtml += '<option value="{{ ac.account_no }}" >{{ ac.account_no }}-'+accountTypeMap[{{ ac.account_type }}]+'</option>';
        {% endfor %}


        $('select[name="account_no"]').append(accountHtml);
        $('select[name="account_no_from"]').append(accountHtml);
        $('select[name="account_no_to"]').append(accountHtml);
        $('select[name="ib_no"]').append(accountHtml);


    }

    initAccountType=function(){//值是账号的下拉框

        // 账户下拉框
        {#var accountHtml = '  <option value="">{{ Lang.form_placeholder_account_no || "账号" }}</option>';#}
        var accountHtml = '';
        {% for ac in account %}
        accountHtml += '<option value="{{ ac.account_type }}" >{{ ac.account_no }}-'+accountTypeMap[{{ ac.account_type }}]+'</option>';
        {% endfor %}

        $('#account_type_create').append(accountHtml);



    }
    initAccountID=function(){//值是账号ID的下拉框
        //账户类型 id-value
        var accountTypeMap = new Object();
        {% for at in Lang.select.member.account.account_type %}
        accountTypeMap[{{ at.value }}] = "{{ at.label }}";
        {% endfor %}
        // 账户下拉框
        var accountHtml = '  <option value="">{{ Lang.form_placeholder_account_no || "账号" }}</option>';
        {% for ac in account %}
        {% if ac.state != 51 %}//账户状态是否禁用
        accountHtml += '<option value="{{ ac.id }}" >{{ ac.account_no }}-'+accountTypeMap[{{ ac.account_type }}]+'</option>';
        {% endif %}
        {% endfor %}

        $('select[name="account_id"]').html(accountHtml);


    }
    initAccountIDType=function(){//值是账号ID的下拉框
        //账户类型 id-value
        var accountTypeMap = new Object();
        {% for at in Lang.select.member.account.account_type %}
        accountTypeMap[{{ at.value }}] = "{{ at.label }}";
        {% endfor %}
        // 账户下拉框
        var accountHtml = '  <option value="">{{ Lang.form_placeholder_account_no || "账号" }}</option>';
        {% for ac in account %}
        {% if ac.state != 51 %}//账户状态是否禁用
        accountHtml += '<option value="{{ ac.id }},{{ ac.account_no }}-'+accountTypeMap[{{ ac.account_type }}]+'" >{{ ac.account_no }}-'+accountTypeMap[{{ ac.account_type }}]+'</option>';
        {% endif %}
        {% endfor %}


        $('select[name="account"]').html(accountHtml);
        $('select[name="account_from"]').html(accountHtml);
        $('select[name="account_to"]').html(accountHtml);


    }



</script>

{#<script type="text/javascript" src="/assets/vendors/jquery-ui-1.9.2/ui/jquery.ui.widget.js"></script>
<script type="text/javascript" src="/assets/vendors/jquery-ui-1.9.2/ui/jquery.ui.dialog.js"></script>#}
{#<link rel="stylesheet" href="/assets/vendors/jquery-ui-1.9.2/themes/base/jquery.ui.all.css">#}
    {% include "./lang.tpl" %}
{%  set version = "v0.5.3" %}


