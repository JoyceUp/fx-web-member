/**
 * Created by zlp on 2018/01/04.
 * For 我的账户
 */
var request = require("superagent");
var API = require("../support/const");
var setting = require("../../../common/cn/member/index");
var banks = require("../../../common/cn/common/banks");
var cache = require("../../../util/cache");
var requestUtil = require("../common/requestUtil");

let templateResult = {
    datas: {},
    setting: setting,
    banks:JSON.stringify(banks),
    banks_option:banks
};
//个人信息
exports.userInfo = {

    page: function (req, res, next) {

        let header = {
            token: req.cookies.token
        };


        let data = {};

        function render() {
            templateResult.active = 'userinfo';
            templateResult.datas = data;
            res.render("member/pages/user/info", templateResult);
        }

        function getBasic() {
            request.get(`${API.member.user.basic_info}`)
                .set(header)
                .end(function (_req, _res) {
                    data.basic = JSON.parse(JSON.parse(_res.text).datas);
                    getIdentity();
                });
        }

        function getIdentity() {
            request.get(`${API.member.user.identity_info}`)
                .set(header)
                .end(function (_req, _res) {
                    data.identity = JSON.parse(JSON.parse(_res.text).datas);
                    getAddress();
                });
        }

        function getAddress() {
            request.get(`${API.member.user.address_info}`)
                .set(header)
                .end(function (_req, _res) {
                    data.address = JSON.parse(JSON.parse(_res.text).datas);
                    render();
                });
        }

        getBasic();
    },

    update: function (req, res, next) {
        let header = {
            token: req.cookies.token
        };

        request.put(`${API.member.user.basic_update}`)
            .query({msg: JSON.stringify(req.body)})
            .set(header)
            .end(function (_req, _res) {
                res.json(requestUtil.resultToJson(_res));
            });
    },
    update_identity: function (req, res, next) {
        let header = {
            token: req.cookies.token
        };
        request.put(`${API.member.user.identity_info}`)
            .query({msg: JSON.stringify(req.body)})
            .set(header)
            .end(function (_req, _res) {
                res.json(requestUtil.resultToJson(_res));
            });
    }

};
//地址信息
exports.address = {
    update: function (req, res, next) {
        let header = {
            token: req.cookies.token
        };

        request.put(`${API.member.user.address_update}`)
            .query({msg: JSON.stringify(req.body)})
            .set(header)
            .end(function (_req, _res) {
                res.json(requestUtil.resultToJson(_res));
            });
    }

};
//银行信息
exports.bankInfo = {
    page: function (req, res, next) {
        let header = {
            token: req.cookies.token
        };

        //let query = {page_no: 1,page_size:10};

        request.get(`${API.member.user.bankcard_list}`)
        //.query({msg: JSON.stringify(query)})
            .set(header)
            .end(function (_req, _res) {
                let result = JSON.parse(JSON.parse(_res.text).datas);
                templateResult.active = 'bankinfo';
                templateResult.datas = result;
                if(result.status == 200){
                    //设置缓存
                    cache.setBankList(JSON.parse(req.cookies.user).user_id, result.items);
                }

                res.render("member/pages/user/bankinfo", templateResult);
            });

    },
    list: function (req, res) {
    },
    info: function (req, res, next) {
        let {id} = req.body;
        let header = {
            token: req.cookies.token
        };

        request.get(`${API.member.user.bankcard_info}/${id}`)
            .query({msg: JSON.stringify(req.body)})
            .set(header)
            .end(function (_req, _res) {
                res.json(requestUtil.resultToJson(_res));
            });

    },
    add: function (req, res, next) {
        let header = {
            token: req.cookies.token
        };

        request.post(`${API.member.user.bankcard_add}`)
            .query({msg: JSON.stringify(req.body)})
            .set(header)
            .end(function (_req, _res) {
                console.log(_res.text)
                let data = JSON.parse(_res.text);
           /*    if(data.status == 200){
                    cache.initBankList(JSON.parse(req.cookies.user).user_id, req.cookies.token, function(d){});
                }*/
                res.json(data);
            });
    },
    del: function (req, res, next) {
        let {id} = req.body;
        let header = {
            token: req.cookies.token
        };
        request.del(`${API.member.user.bankcard_delete}/${id}`)
            .set(header)
            .end(function (_req, _res) {
                let data = JSON.parse(_res.text);
                if(data.status == 200){
                    cache.initBankList(JSON.parse(req.cookies.user).user_id, req.cookies.token, function(d){});
                }
                res.json(data);
            });

    },
    update: function (req, res, next) {
        let {id} = req.body;
        let header = {
            token: req.cookies.token
        };
        request.put(`${API.member.user.bankcard_update}`)
            .query({msg: JSON.stringify(req.body)})
            .set(header)
            .end(function (_req, _res) {
                let data = JSON.parse(_res.text);
                if(data.status == 200){
                    cache.initBankList(JSON.parse(req.cookies.user).user_id, req.cookies.token, function(d){});
                }
                res.json(data);
            });
    }
};
//电汇信息
exports.telInfo = {

    page: function (req, res, next) {


        let header = {
            token: req.cookies.token
        };
        request.get(`${API.member.user.tt_info}`)
            .set(header)
            .end(function (_req, _res) {
                if(_res.text){
                    let datas = JSON.parse(_res.text).datas
                    let result = JSON.parse(datas);
                    templateResult.active = 'telinfo';
                    templateResult.datas = result;
                    res.render("member/pages/user/telinfo", templateResult)
                }

            });


    },
    list: function (req, res) {
    },
    info: function (req, res) {
    },
    add: function (req, res, next) {
        let header = {
            token: req.cookies.token
        };
        request.post(`${API.member.user.tt_add}`)
            .query({msg: JSON.stringify(req.body)})
            .set(header)
            .end(function (_req, _res) {
                res.json(requestUtil.resultToJson(_res));
            });
    },
    del: function (req, res) {
    },
    update: function (req, res, next) {

        let header = {
            token: req.cookies.token
        };

        request.put(`${API.member.user.tt_update}`)
            .query({msg: JSON.stringify(req.body)})
            .set(header)
            .end(function (_req, _res) {
                let data = JSON.parse(_res.text);
                if(data.status == 200){
                    cache.initTTInfo(JSON.parse(req.cookies.user).user_id, req.cookies.token, function(d){});
                }
                res.json(data);
            });
    }

};
//投资者信息
exports.workInfo = {
    page: function (req, res, next) {
        let header = {
            token: req.cookies.token
        };
        request.get(`${API.member.user.investor_info}`)
            .set(header)
            .end(function (_req, _res) {
                let result = JSON.parse(JSON.parse(_res.text).datas);

                templateResult.active = 'workinfo';
                templateResult.datas = result;
                res.render("member/pages/user/workinfo", templateResult);
            });
    },
    list: function (req, res) {
    },
    info: function (req, res) {
    },
    add: function (req, res) {
    },
    del: function (req, res) {
    },
    update: function (req, res, next) {

        let header = {
            token: req.cookies.token
        };

        request.put(`${API.member.user.investor_update}`)
            .query({msg: JSON.stringify(req.body)})
            .set(header)
            .end(function (_req, _res) {
                res.json(requestUtil.resultToJson(_res));
            });
    }

};





