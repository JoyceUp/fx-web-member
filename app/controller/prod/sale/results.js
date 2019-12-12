/**
 * Created by sozt on 2018/1/11.
 * For 销售系统
 */

var request = require("superagent");
var API = require("../support/const");
var requestUtil = require("../common/requestUtil");
var setting = require("../../../common/cn/sale/index");


let templateResult = {
    datas: {},
    setting: setting
};

//提成列表
exports.page = function (req, res, next) {
    templateResult.active = "results";
    res.render("sale/pages/results", templateResult)
};

//获取每天提成列表
exports.detail = function (req, res, next) {
    let {page, limit, start_time, end_time,account_no} = req.body;
    let params = {
        "condition": {
            "start_time": start_time,
            "account_no": account_no
        },
        "page_no": page,
        "page_size": limit
    };
    let header = {
        token: req.cookies.saletoken,
    };

    request.get(API.sale.results.detail)
        .query({msg: JSON.stringify(params)})
        .set(header)
        .end(function (_req, _res) {
            requestUtil.formatTableData(_res).then(function (returnData) {
               // res.json(returnData);
                if(returnData.statistics){
                    returnData.datas.push({statistics: 1, sum_reward_amount_by_cause: returnData.statistics.sum_reward_amount_by_cause, sum_reward_amount_by_cause2: returnData.statistics.sum_reward_amount_by_cause2,sum_reward_amount:returnData.statistics.sum_reward_amount})
                }
                res.json(returnData);
            });
        });
};


//业绩列表
exports.list = function (req, res, next) {
    let {page, limit, start_time, end_time} = req.body;
    let header = {
        token: req.cookies.saletoken
    };
    let params = {
        page_size: 10,
        page_no: 1,
        "order_column":"performance_date",
        "order_by":"desc",
        condition: {
            start_time: start_time,
            end_time: end_time
        }
    };

    request.get(API.sale.results.list)
        .query({msg: JSON.stringify(params)})
        .set(header)
        .end(function (_req, _res) {
            requestUtil.formatTableData(_res).then(function (returnData) {
                res.json(returnData);
            });
        });
}
//返利详情
exports.rebate = function (req, res, next) {
    let {page, limit, start_time, account_no,source_account_no,source_account_full_name,_id,_start_time} = req.body;
    let header = {
        token: req.cookies.saletoken
    };
    let params = {
        "condition": {
            "start_time": start_time || _start_time,
            "account_no": account_no || _id,
            "source_account_no": source_account_no,
            "source_account_full_name": source_account_full_name,
        },
        "page_size":  limit,
        "page_no":page,
    };
    console.log(params)
    request.get(API.sale.results.rebate)
        .query({msg: JSON.stringify(params)})
        .set(header)
        .end(function (_req, _res) {
            requestUtil.formatTableData(_res).then(function (returnData) {
                res.json(returnData);
            });
        });
}
//交易返佣详情
exports.commission = function (req, res, next) {
    let {page, limit, start_time, account_no,source_account_no,source_account_full_name,mt4_order_no,_id,_start_time} = req.body;
    let header = {
        token: req.cookies.saletoken
    };
    let params = {
        "condition": {
            "start_time": start_time || _start_time,
            "account_no": account_no || _id,
            "source_account_no": source_account_no,
            "source_account_full_name": source_account_full_name,
            "mt4_order_no": mt4_order_no,
        },
        "page_size": limit,
        "page_no": page,
    };

    request.get(API.sale.results.commission)
        .query({msg: JSON.stringify(params)})
        .set(header)
        .end(function (_req, _res) {
            requestUtil.formatTableData(_res).then(function (returnData) {
                res.json(returnData);
            });
        });
}

//销售提成明细
exports.common_results_reward = {
    //代理客户交易提成
    list_ecn:function(req,res,next){
        let {page, limit,gmt_create,owner_id,mt4_order_no,source_account_no,source_account_full_name,account_full_no,account_full_name,_id,_start_time} = req.body;
        let header = {
            token: req.cookies.saletoken
        };
        let role_id = JSON.parse(req.cookies.user).user_id;
        let params = {
                "condition":{
                "gmt_create": gmt_create || _start_time,
                "owner_id": owner_id || _id,
                "mt4_order_no": mt4_order_no,
                "source_account_no": source_account_no,
                "source_account_full_name":source_account_full_name,
                "account_no": account_full_no ,
                "full_name": account_full_name
            },
            "page_size": limit,
            "page_no": page,
        };
        console.log(params)
        request.get(API.sale.results.common_results_reward_list_ecn)
            .query({msg: JSON.stringify(params)})
            .set(header)
            .end(function (_req, _res) {
                requestUtil.formatTableData(_res).then(function (returnData) {
                    res.json(returnData);
                });
            });
    },
    //代理收益提成
    list_common:function(req,res,next){
        let {page, limit,gmt_create,owner_id,account_full_no,account_full_name,_id,_start_time} = req.body;
        let header = {
            token: req.cookies.saletoken
        };
        let role_id = JSON.parse(req.cookies.user).user_id;
        let params = {
            "page_size":limit ,
            "page_no": page,
            "condition":{
                "gmt_create": gmt_create || _start_time,
                "role_id": owner_id || _id,
                "source_account_no": account_full_no,
                "source_account_full_name": account_full_name,
            }
        };
        console.log(params);
        request.get(API.sale.results.common_results_reward_list_common)
            .query({msg: JSON.stringify(params)})
            .set(header)
            .end(function (_req, _res) {
                requestUtil.formatTableData(_res).then(function (returnData) {
                    res.json(returnData);
                });
            });
    }
}


//销售总监 提成明细
exports.department_results_reward = {
    //部门客户交易提成
    list_ecn:function(req,res,next){
        let {page, limit,start_time,account_no,mt4_order_no,source_account_no,source_account_full_name,account_full_no,_id,_start_time,account_full_name} = req.body;
        let header = {
            token: req.cookies.saletoken
        };
        let role_id = JSON.parse(req.cookies.user).user_id;
        let params = {
            "condition":{
                "gmt_create":  start_time || _start_time,
                "owner_id": account_no || _id,
                "mt4_order_no": mt4_order_no,
                "source_account_no": source_account_no,
                "source_account_full_name":source_account_full_name,
                "account_no": account_full_no,
                "full_name": account_full_name
            },
            "page_size": limit,
            "page_no": page,
        };
        console.log(params)
        request.get(API.sale.results.department_sale_results_list_ecn)
            .query({msg: JSON.stringify(params)})
            .set(header)
            .end(function (_req, _res) {
                requestUtil.formatTableData(_res).then(function (returnData) {
                    res.json(returnData);
                });
            });
    },
    //销售收益提成
    list_common:function(req,res,next){
        let {page, limit,start_time,account_no,account_full_name,account_full_no,_id,_start_time} = req.body;
        let header = {
            token: req.cookies.saletoken
        };
        let role_id = JSON.parse(req.cookies.user).user_id;
        let params = {
            "condition":{
                "gmt_create": start_time || _start_time,
                "role_id": role_id || _id,
                "source_account_no": account_full_no,
                "source_account_full_name": account_full_name,
            },
            "page_size": limit,
            "page_no": page,
        };
        request.get(API.sale.results.department_sale_results_list_common)
            .query({msg: JSON.stringify(params)})
            .set(header)
            .end(function (_req, _res) {
                requestUtil.formatTableData(_res).then(function (returnData) {
                    res.json(returnData);
                });
            });
    }
}