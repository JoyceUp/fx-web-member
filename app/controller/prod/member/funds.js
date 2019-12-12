/**
 * Created by zlp on 2018/01/04.
 * For 资金信息
 */
var request = require("superagent");
var API = require("../support/const")
var setting = require("../../../common/cn/member/index");
var requestUtil = require("../common/requestUtil");
var cache = require("../../../util/cache");

let templateResult = {
    datas: {},
    setting: setting
};

//资金记录
exports.fundsrecord = {
    page: function (req, res, next) {
        templateResult.active = "funds_record";
        cache.getAccountList(JSON.parse(req.cookies.user).user_id, req.cookies.token, 1).then(function (data) {
            templateResult.account = data;
            res.render("member/pages/funds/fundsrecord", templateResult)
        });
    },

    list: function (_req, _res, next) {
        let {page, limit, account_no, type, start_time, end_time, field, order} = _req.body;
        let param = {
            "condition": {account_no: account_no, "start_time": start_time, "end_time": end_time, "type": type},
            "page_size": limit,
            "page_count": 0,
            "page_no": page,
            order_column: field || 'gmt_create',
            order_by: order || 'desc',
        };
        request.get(API.member.funds.funds_list)
            .query({msg: JSON.stringify(param)})
            .set("token", _req.cookies.token)
            .end(function (req, res) {
                requestUtil.formatTableData(res).then(function (returnData) {
                    _res.json(returnData)
                })

            });
    }
};


//出入金记录
exports.deposit = {
    page: function (req, res, next) {
        templateResult.active = "funds_deposit";
        cache.getAccountList(JSON.parse(req.cookies.user).user_id, req.cookies.token, 1).then(function (data) {
            templateResult.account = data;
            res.render("member/pages/funds/deposit", templateResult)
        });
    },

    list: function (_req, _res, next) {
        let {page, limit, account_no, type, channel_type, status, start_time, end_time, field, order} = _req.body;
        if (type == null || type == '') { //非空参数
            type = 0;
        }
        let params = {
            "page_size": limit,
            "page_count": 0,
            "page_no": page,
            order_column: field || 'gmt_create',
            order_by: order || 'desc',
            "condition": {
                account_no: account_no,
                "start_time": start_time,
                "end_time": end_time,
                "type": type,
                "channel_type": channel_type,
                "status": status
            }
        };
        let header = {
            token: _req.cookies.token
        };
        request.get(API.member.funds.dep_draw_list)
            .query({msg: JSON.stringify(params)})
            .set(header)
            .end(function (req, res) {
                requestUtil.formatTableData(res).then(function (returnData) {
                    _res.json(returnData)
                });
            });

    },

    info: function (_req, _res, next) {
        let {id, type} = _req.body;
        let header = {
            token: _req.cookies.token
        };
        let params = {
            type: type
        }
        request.get(API.member.funds.dep_draw_info + id)
            .query({msg: JSON.stringify(params)})
            .set(header)
            .end(function (req, res) {
                if (res.status == 200) {
                    _res.json(requestUtil.resultToJson(res));
                }
            })

    },
    cancel: function (_req, _res, next) {
        let {id, channel_type} = _req.body;

        let header = {
            token: _req.cookies.token
        };
        let params = {
            id: id,
            type: channel_type
        };
        request.put(API.member.funds.dep_draw_cancel)
            .query({msg: JSON.stringify(params)})
            .set(header)
            .end(function (req, res) {
                if (res.status == 200) {
                    _res.json(requestUtil.resultToJson(res));
                }
            });
    }
};

//转账记录
exports.transfer = {
    page: function (req, res, next) {
        templateResult.active = "funds_transfer";
        cache.getAccountList(JSON.parse(req.cookies.user).user_id, req.cookies.token, 1).then(function (data) {
            templateResult.account = data;
            res.render("member/pages/funds/transfer", templateResult)
        });
    },
    list: function (_req, _res, next) {
        let {page, limit, account_no_from, account_no_to, state, type, start_time, end_time, field, order} = _req.body;
        let params = {
            "page_no": page,
            "page_size": limit,
            order_column: field || 'gmt_create',
            order_by: order || 'desc',
            "condition": {
                "account_no": account_no_from,
                "target_account_no": account_no_to,
                "type": type,
                status: state,
                start_time: start_time,
                end_time: end_time
            }
        };
        let header = {
            token: _req.cookies.token
        };
        request.get(API.member.funds.transfer_list)
            .query({msg: JSON.stringify(params)})
            .set(header)
            .end(function (req, res) {
                requestUtil.formatTableData(res).then(function (returnData) {
                    _res.json(returnData)
                });
            })


    },

    info: function (_req, _res, next) {
        let {id} = _req.body;

        let header = {
            token: _req.cookies.token
        };
        request.get(API.member.funds.transfer_info + "/" + id)
            .set(header)
            .end(function (req, res) {
                _res.json(requestUtil.resultToJson(res));
            });
    },
}

//余额清零记录
exports.blanceflush = {
    page: function (req, res, next) {
        templateResult.active = "funds_balance_flush";
        cache.getAccountList(JSON.parse(req.cookies.user).user_id, req.cookies.token, 1).then(function (data) {
            templateResult.account = data;
            res.render("member/pages/funds/blanceflush", templateResult)
        });
    },

    list: function (_req, _res, next) {
        let {page, limit, account_no, state, field, order} = _req.body;
        let params = {
            "page_no": page,
            "page_size": limit,
            order_column: field || 'gmt_create',
            order_by: order || 'desc',
            "condition":
                {"account_no": account_no, "status": state},
        };
        let header = {
            token: _req.cookies.token
        };
        request.get(API.member.funds.bal_clear_list)
            .query({msg: JSON.stringify(params)})
            .set(header)
            .end(function (req, res) {
                requestUtil.formatTableData(res).then(function (returnData) {
                    _res.json(returnData)
                });
            });
    },

    info: function (_req, _res, next) {
        let {id} = _req.body;

        let header = {
            token: _req.cookies.token
        };
        request.get(API.member.funds.bal_clear_info + '/' + id)
            .set(header)
            .end(function (req, res) {

                _res.json(requestUtil.resultToJson(res));
            });
    }
};
//交易记录
exports.transaction = {
    page: function (_req, _res, next) {
        templateResult.active = "funds_transaction";
        _res.render("member/pages/funds/transaction", templateResult)
    },

    list: function (_req, _res, next) {
        let {page, limit, id, account_no_from, account_no_to, start_time, end_time, state, field, order} = _req.body;
        let params = {
            "condition":
                {"start_time": start_time, "end_time": end_time, "state": state},
            "page_size": limit,
            "page_count": 0,
            "page_no": page,
            order_column: field || 'gmt_create',
            order_by: order || 'desc',
        };
        let header = {
            token: _req.cookies.token
        };

        request.get(API.member.funds.trade_list)
            .query({msg: JSON.stringify(params)})
            .set(header)
            .end(function (req, res) {
                requestUtil.formatTableData(res).then(function (returnData) {
                    _res.json(returnData)
                });
            })


    },

    info: function (_req, _res, next) {
        let {id} = _req.body;

        let header = {
            token: _req.cookies.token
        };

        request.get(API.member.funds.trade_info + '/' + id)
            .set(header)
            .end(function (req, res) {
                _res.json(requestUtil.resultToJson(res));
            })

    }
};