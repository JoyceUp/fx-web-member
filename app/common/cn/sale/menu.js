module.exports = [
   /* {
        key: "home", label: '首页', url: "/sale/home", children: []
    }
    ,*/

    {
        key: "", label: '客户信息', url: "", children: [
            {key: "customer", label: '客户列表', url: "/sale/customer"}
        ]
    }
    ,
    {
        key: "", label: '代理信息', url: "", children: [
            {key: "ib", label: '代理列表', url: "/sale/ib/page"}
        ]
    },
    {
        key: "", label: '我的业绩', url: "", children: [
            {key: "results", label: '我的业绩', url: "/sale/results"}
        ]
    }
    ,
    {
        key: "rebate", label: '返佣返利信息', url: "", children: [
            {key: "trade", label: '交易返佣记录', url: "/sale/rebate/trade"}
            , {key: "balance", label: '余额返利记录', url: "/sale/rebate/balance"}
        ]
    },
    {
        key: "", label: '提成信息', url: "", children: [
            {key: "bonus", label: '提成列表', url: "/sale/bonus"}
        ]
    },
    {
        key: "userinfo", label: '用户信息', url: "/sale/userinfo", children: []
    }
    ,
    {
        key: "invitation", label: '邀请管理', url: "/sale/invite/page", children: []
    }

]
