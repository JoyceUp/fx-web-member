/**
 * Created by zlp on 2018/01/04.
 * For 我的账户
 */
var request = require("superagent");
var API = require("../support/const");
var setting = require("../../../common/cn/member/index");
var cache = require("../../../util/cache");
var money = require("../../../util/money");
var requestUtil = require("../common/requestUtil");

let templateResult = {
    datas: {},
    setting: setting
}
//#资金交易
//账户入金
exports.deposit =  {
    page: function (req, res, next) {
        let header = {
            token: req.cookies.token
        };
        templateResult.active = "deposit";
        let host = req.hostname;
        if (host.indexOf("172.7") > -1 || host.indexOf("localhost") > -1) {
            templateResult.payUrl = "http://p.xinanchuangying.com/mdffx-payserv/api/v1/customer/deposit/";
        } else {
            templateResult.payUrl = "http://www.xinanchuangying.com/mdffx-payserv/api/v1/customer/deposit/";
        }
        //templateResult.payUrl.wechat = "http://www.xinanchuangying.com/mdffx-payserv/api/v1/customer/deposit/bankcard";
        cache.getAccountList(JSON.parse(req.cookies.user).user_id, req.cookies.token, 1).then(function (data) {
            templateResult.account = data;
            //获取汇率
            // deposit_exchangerate	入金
            // withdraw_exchangerate	出金
            request.get(`${API.common.get_rate}`)
                .query({msg: JSON.stringify({type: "deposit_exchange_rate"})})
                .end(function (_req, _res) {
                    //记录用户操作日志
                    let data = JSON.parse(_res.text);
                    if(data.status == 200) {
                        let datas = JSON.parse(data.datas);
                        // templateResult.rate = datas.rate;
                        templateResult.rate = data.datas / 10000;
                        cache.setRate(templateResult.rate, 'deposit_exchange_rate');
                    }

                    //获取系统参数
                    request.get(`${API.common.system_setting}`)
                        .set(header)
                        .end(function (_req, _res) {
                            let data = requestUtil.resultToJson(_res);
                            if(data.datas){
                                console.log(data.datas)
                                templateResult.system_setting = JSON.parse(data.datas);
                            }
                            res.render("member/pages/transaction/deposit", templateResult)
                        });
                });
        });

    },
    //确认入金 type  2电汇
    submitDeposit: function (req, res, next) {
        let {account_id, pay_amount, amount, rate, tt_path, type} = req.body;
        let header = {
            token: req.cookies.token
        };
        let params = {
            account_id : account_id,
            pay_amount: money.toServer(pay_amount),
            amount: money.toServer(amount),
            tt_path: tt_path,
            rate: rate
        };

        let url = '';
        switch(type){
            case '1':
                url = `${API.member.transaction.bankcard_deposit}`;
                break;
            case '2':
                url = `${API.member.transaction.tt_deposit}`;
                break;
            case '3':
                url = `${API.member.transaction.wechat_deposit}`;
                break;
            default:
                break;
        }
        request.put(url)
            .query({msg: JSON.stringify(params)})
            .set(header)
            .end(function (_req, _res) {
                res.json(requestUtil.resultToJson(_res));
            });
    },
    resultPage: function (req, res, next) {
        let {user_id, status, order_no, amount} = req.query;  //status 200
        // TODO redis
        cache.depositSuccess(user_id, status);
        // templateResult.active = "deposit";
        res.render("member/pages/transaction/depositResult", templateResult)
    },
    checkDeposit: function (req, res, next) {
        let status = cache.checkDeposit(JSON.parse(req.cookies.user).user_id);
        res.json({status: status});
    }

};
//账户出金
exports.withdraw = {
    page: function (req, res, next) {
        let header = {
            token: req.cookies.token
        };
        templateResult.active = "withdraw";
        cache.getAccountList(JSON.parse(req.cookies.user).user_id, req.cookies.token, 1).then(function (data) {
            templateResult.account = data;
            //获取银行卡列表
            cache.getBankList(JSON.parse(req.cookies.user).user_id, req.cookies.token, 1).then(function (data) {
                templateResult.banklist = data;
                //获取电汇信息
                cache.getTTInfo(JSON.parse(req.cookies.user).user_id, req.cookies.token, 1).then(function (data) {
                    templateResult.tt = data;
                    //获取汇率
                    // deposit_exchangerate	入金
                    // withdraw_exchangerate	出金
                    request.get(`${API.common.get_rate}`)
                        .query({msg: JSON.stringify({type: "withdraw_exchange_rate"})})
                        .end(function (_req, _res) {
                            //记录用户操作日志
                            let data = JSON.parse(_res.text);
                            if(data.status == 200) {
                                let datas = JSON.parse(data.datas);
                                // templateResult.rate = datas.rate;
                                templateResult.rate = data.datas / 10000;
                                cache.setRate(templateResult.rate, 'withdraw_exchange_rate');
                            }
                            //获取系统参数
                            request.get(`${API.common.system_setting}`)
                                .set(header)
                                .end(function (_req, _res) {
                                    let data = requestUtil.resultToJson(_res);
                                    if(data.datas){
                                        templateResult.system_setting = JSON.parse(data.datas);
                                    }
                                    res.render("member/pages/transaction/withdraw", templateResult)
                                });
                        });
                });
            });
        });

    },
    //确认出金 type 1银行卡 2电汇
    submitWithdraw: function (req, res, next) {
        let {account_id, pay_amount, rate, amount, bankcard_id, bankcard_no, fee, remark, type} = req.body;
        let header = {
            token: req.cookies.token
        };
        let params = {
            account_id : account_id,
            pay_amount: money.toServer(pay_amount),                         //人民币金额
            rate: rate,
            amount: money.toServer(amount),                                 //美元金额
            bankcard_id: bankcard_id,
            bankcard_no: bankcard_no,
            fee: money.toServer(fee),
            remark: remark
        };
        let url = '';
        switch(type){
            case '1':
                url = `${API.member.transaction.bankcard_withdraw}`;
                break;
            case '2':
                url = `${API.member.transaction.tt_withdraw}`;
                break;
            default:
                break;
        }
        request.put(url)
            .query({msg: JSON.stringify(params)})
            .set(header)
            .end(function (_req, _res) {
                res.json(requestUtil.resultToJson(_res))
            });
    },
    //出金手续费
    withdrawFee: function (req, res, next) {
        let header = {
            token: req.cookies.token
        };
        request.get(`${API.member.transaction.fee_withdraw}`)
            .set(header)
            .end(function (_req, _res) {
                res.json(requestUtil.resultToJson(_res))
            });
    },
    //出金取消
    cancelWithdraw: function (req, res, next) {
        let {id, type} = req.body;
        let header = {
            token: req.cookies.token
        };
        let params = {
            order_id : id,
            type: type
        };
        request.put(`${API.member.transaction.cancel_withdraw}`)
            .query({msg: JSON.stringify(params)})
            .set(header)
            .end(function (_req, _res) {
                res.json(requestUtil.resultToJson(_res))
            });
    }
};

//账户转账
exports.transfer = {
    page: function (req, res, next) {
        templateResult.active = "transfer";
        cache.getAccountList(JSON.parse(req.cookies.user).user_id, req.cookies.token, 1).then(function (data) {
            templateResult.account = data;
            res.render("member/pages/transaction/transfer", templateResult);
        });
    },
    //确认转账
    submitTransfer: function (req, res, next) {
        let {account_id_from, account_id_to, transfer_amount} = req.body;
        let header = {
            token: req.cookies.token
        };
        let params = {
            from_account_id : account_id_from,
            target_account_id: account_id_to,
            amount: money.toServer(transfer_amount)
        };
        request.put(`${API.member.transaction.transfer}`)
            .query({msg: JSON.stringify(params)})
            .set(header)
            .end(function (_req, _res) {
                res.json(requestUtil.resultToJson(_res))
            });
    },
    //转账取消
    cancelTransfer: function (req, res, next) {
        let {id, type} = req.body;
        let header = {
            token: req.cookies.token
        };
        let params = {
            order_id : id,
            type: type
        };
        request.put(`${API.member.transaction.cancel_transfer}`)
            .query({msg: JSON.stringify(params)})
            .set(header)
            .end(function (_req, _res) {
                res.json(requestUtil.resultToJson(_res))
            });
    }
};