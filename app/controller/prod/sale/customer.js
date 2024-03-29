/**
 * Created by 翟凤禄 on 2018/1/11.
 * For 销售系统
 */
var request = require("superagent");
var API = require("../support/const")
var setting = require("../../../common/cn/sale/index");
var requestUtil = require("../common/requestUtil");
let templateResult = {
    datas: {},
    setting: setting
};


//#客户信息
//客户列表
exports.customers ={
    page: function (req, res, next) {
        templateResult.active = "customer";
        res.render("sale/pages/customer/list",templateResult)
    },
    list: function (req,res,next) {
        let {page,limit,customer_name,account_no,email, field, order} = req.body;

        let header = {
            token:req.cookies.saletoken
        };
        if(customer_name){
            customer_name = customer_name.trim();
        };
        if(account_no){
            account_no = account_no.trim();
        };

        if(email){
            email = email.trim();
        };
        let params = {
            "condition": {"customer_name":customer_name,"account_no":account_no,"email":email},
            "page_size": limit,
            "page_count": 0,
            "page_no": page,
            order_column: field || 'gmt_create',
            order_by: order || 'desc',
        };
        request.get(API.sale.customer.customer_list)
            .query({msg:JSON.stringify(params)})
            .set(header)
            .end(function(_req,_res){
                if(_res.status == 200) {
                    requestUtil.formatTableData(_res).then(function (returnData) {
                        res.json(returnData)
                    })
                }
            });
    },
    info: function(req,res,next) {
        let id = req.query.cid;
        let header = {
            token:req.cookies.saletoken
        };
        let params = {
            id : id
        };

        if(id) {
            request.get(API.sale.customer.basic_info)
                .query({msg:JSON.stringify(params)})
                .set(header)
                .end(function (_req, _res) {
                    if (_res.status == 200) {
                        templateResult.datas.info = JSON.parse(JSON.parse(_res.text).datas);
                            //获取客户地址
                            request.get(API.sale.customer.address_info)
                                .query({msg:JSON.stringify(params)})
                                .set(header)
                                .end(function (_req1, _res1) {
                                    templateResult.datas.address = JSON.parse(JSON.parse(_res1.text).datas);
                                    //获取客户证件信息
                                    request.get(API.sale.customer.identity_info)
                                        .query({msg:JSON.stringify(params)})
                                        .set(header)
                                        .end(function(_req2,_res2){
                                            templateResult.datas.identity = JSON.parse(JSON.parse(_res2.text).datas);
                                            res.render("sale/pages/customer/info", templateResult)
                                        });
                                });

                    }
                });
        }

    }
}

//客户详情
exports.customer_info = {
        //账户信息
    account_list:function(req, res, next) {
        let{page,limit, field, order} = req.body;
        let customer_id = req.body.cid;
        let params = {
            "page_no": page,
            "page_size": limit,
            order_column: field || 'gmt_create',
            order_by: order || 'desc',
            "customer_id": customer_id
        };

        let header = {
            token:req.cookies.saletoken
        };
        request.get(API.sale.customer.account_list)
            .query({msg:JSON.stringify(params)})
            .set(header)
            .end(function (_req,_res) {
                if(_res.status == 200) {
                    requestUtil.formatTableData(_res).then(function (returnData) {
                        res.json(returnData)
                    });
                }
            });
    },
    //出入金信息
    deposit_list: function (req, res, next) {
        let {page,limit, field, order} = req.body;
        let customer_id = req.body.cid;
        let params = {
            "page_no": page,
            "page_size": limit,
            order_column: field || 'gmt_create',
            order_by: order || 'desc',
            "condition":
                {"customer_id": customer_id,"type":0}//type 出入金=0,出金=1,入金=2
        };

        let header = {
            token:req.cookies.saletoken
        };

        request.get(API.sale.customer.dep_draw_list)
            .query({msg:JSON.stringify(params)})
            .set(header)
            .end(function (_req,_res) {
                if(_res.status == 200) {
                    requestUtil.formatTableData(_res).then(function (returnData) {
                        res.json(returnData)
                    });
                }
            });

    },
    //取消申请
    cancel:function(req, res, next){
        let{id} = req.body;
        let params = {
            id : id
        };
        let header = {
            token:req.cookies.saletoken
        };
        request.get(API.sale.customer.cancel)
            .query({msg:JSON.stringify(params)})
            .set(header)
            .end(function(_req,_res){
                if(_res.status == 200){
                    res.json(JSON.parse(_res.text));
                }
            });
    },
    //转账信息
    transfer_list: function (req, res, next) {
        let {page,limit, field, order} = req.body;
        let customer_id = req.body.cid;
        let params = {
            "page_no": page,
            "page_size": limit,
            order_column: field || 'gmt_create',
            order_by: order || 'desc',
            "condition":
                {"customer_id": customer_id}
        };

        let header = {
            token:req.cookies.saletoken
        };
        request.get(API.sale.customer.transfer_list)
            .query({msg:JSON.stringify(params)})
            .set(header)
            .end(function (_req,_res) {
                requestUtil.formatTableData(_res).then(function(returnData){
                    res.json(returnData)
                });
            });
    },
    //交易信息
    transaction: function (req, res, next) {
        let {page,limit, field, order} = req.body;
        let customer_id = req.body.cid;
        let params = {
            "page_no": page,
            "page_size": limit,
            order_column: field || 'gmt_create',
            order_by: order || 'desc',
            "condition":
                {"customer_id": customer_id}
        };

        let header = {
            token:req.cookies.saletoken
        };

        request.get(API.sale.customer.trade_list)
            .query({msg:JSON.stringify(params)})
            .set(header)
            .end(function (_req,_res) {
                if(_res.status == 200) {
                    requestUtil.formatTableData(_res).then(function (returnData) {
                        res.json(returnData)
                    });
                }
            });

    }
}