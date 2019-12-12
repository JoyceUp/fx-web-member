/**
 * Created by cuiyajuan on 2018/01/10.
 * For 注册
 */

var request = require("superagent");
var API = require("../support/const");
var select = require("../../../common/cn/member/select");
var requestUtil = require("../common/requestUtil");

let result = {
    title:"真实账户开立",
    select: select.register
};

exports.page = function (req, res, next) {
    let no = req.query.no;
    result.no = no;
    res.render("kh/pages/register", result)
};

exports.step1 = function (_req, _res, _next) {
    request.post(`${API.member.reg.step1}`)
        .query({msg:JSON.stringify(_req.body)})
        //.set(header)
        .end(function (req,res){
            _res.json(requestUtil.resultToJson(res));
        });
};
/*验证邮箱唯一性*/
exports.email_unique = function (_req, _res, _next) {
    request.get(`${API.common.email_unique}`)
        .query({msg:JSON.stringify(_req.query)})
        .end(function (req,res){
            if(res.text){
                _res.json(requestUtil.resultToJson(res));
            }

        });
};
/*获取验证码*/
exports.verify_code = function (_req, _res, _next) {
    request.get(`${API.common.send_email_verify_code}`)
        .query({msg:JSON.stringify(_req.query)})
        .end(function (req,res){
            if(res.text){
                _res.json(requestUtil.resultToJson(res));
            }

        });
};

exports.step2 = function (_req, _res, _next) {
    request.post(`${API.member.reg.step2}`)
        .query({msg:JSON.stringify(_req.body)})
        .end(function (req,res){
            _res.json(requestUtil.resultToJson(res));
        });
};
exports.step3 = function (_req, _res, _next) {
    request.post(`${API.member.reg.step3}`)
        .query({msg:JSON.stringify(_req.body)})
        .end(function (req,res){
            _res.json(requestUtil.resultToJson(res));
        });
};

/*
exports.images = function(_req, _res, _next){
    request.post(`${API.common.upload_img}`)
        .query({msg:JSON.stringify(_req.body)})
        .end(function (req,res){
            _res.json(requestUtil.resultToJson(res));
        });
}*/
