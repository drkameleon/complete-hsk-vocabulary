exports.tests = [
	{value:true,  tests:[{json:"true"  }]},
	{value:false, tests:[{json:"false" }]},
	// {value:nil,   tests:[{json:"null"  }]},
	{value:null,     tests:[{json:"null"  }]},
	{value:undefined,tests:[{json:"null"  }]},
	{value:5,     tests:[
		{json:"5"},
		{json:"5", opts:{decimals:3}},
	]},
	{value:5.0, tests:[
		{json:"5"},
		{json:"5", opts:{decimals:3}},
	]},
	{value:5.0001, tests:[
		{json:"5.0001"},
		{json:"5.000", opts:{decimals:3}},
		{json:"5",     opts:{decimals:3, trimTrailingZeros:true}},
		{json:"5.0",   opts:{decimals:3, trimTrailingZeros:true, forceFloats:true}},
		{json:"5.000", opts:{decimals:3, trimTrailingZeros:false, forceFloats:true}},
	]},
	{value:4.2, tests:[
		{json:"4.2"},
		{json:"4",   opts:{decimals:0}},
		{json:"4.20",opts:{decimals:2}},
	]},
	{value:4.199, tests:[{json:"4.20", opts:{decimals:2}}]},
	{value:4.204, tests:[{json:"4.20", opts:{decimals:2}}]},
	{value:-1.9,  tests:[{json:"-2",   opts:{decimals:0}}]},
	{value:-2.4,  tests:[{json:"-2",   opts:{decimals:0}}]},
	{value:1e23,  tests:[{json:/1(?:\.0+)?e\+23/i}]},
	{value:1e-9,  tests:[{json:/1(?:\.0+)?e-0*9/i}]},
	{value:-2.4,  tests:[{json:"-2",   opts:{decimals:0}}]},

	{value:"foo",       tests:[{json:"\"foo\""}]},
	{value:"foo\nbar",  tests:[{json:"\"foo\\nbar\""}]},
	{value:"foo\tbar",  tests:[{json:"\"foo\\tbar\""}]},
	{value:"foo\rbar",  tests:[{json:"\"foo\\rbar\""}]},
	{value:"foo\bbar",  tests:[{json:"\"foo\\bbar\""}]},
	{value:"foo\fbar",  tests:[{json:"\"foo\\fbar\""}]},

	{value:"foo${no}bar",  tests:[{json:"\"foo${no}bar\""}]},
	{value:"foo\#{no}bar",  tests:[{json:"\"foo\#{no}bar\""}]},
	{value:"foo\\bar",  tests:[{json:"\"foo\\\\bar\""}]},
	{value:"foo/bar",  tests:[{json:"\"foo/bar\""}]},

	{value:[1,2,3,4,[5,6,7,[8,9,10],11,12]], tests:[
		{ json:"[1,2,3,4,[5,6,7,[8,9,10],11,12]]" },
		{ json:"[\n  1,\n  2,\n  3,\n  4,\n  [5,6,7,[8,9,10],11,12]\n]", opts:{wrap:30} },
		{ json:"[\n  1,\n  2,\n  3,\n  4,\n  [\n    5,\n    6,\n    7,\n    [8,9,10],\n    11,\n    12\n  ]\n]", opts:{wrap:20} },
		{ json:"[\n  1,\n  2,\n  3,\n  4,\n  [\n    5,\n    6,\n    7,\n    [\n      8,\n      9,\n      10\n    ],\n    11,\n    12\n  ]\n]", opts:{wrap:true} },
		{ json:"[\n\t1,\n\t2,\n\t3,\n\t4,\n\t[\n\t\t5,\n\t\t6,\n\t\t7,\n\t\t[\n\t\t\t8,\n\t\t\t9,\n\t\t\t10\n\t\t],\n\t\t11,\n\t\t12\n\t]\n]", opts:{wrap:true,indent:"\t"} },
		{ json:"[1,2,3,4,[5,6,7,[8,9,10],11,12]]", opts:{arrayPadding:0} },
		{ json:"[ 1,2,3,4,[ 5,6,7,[ 8,9,10 ],11,12 ] ]", opts:{arrayPadding:1} },
		{ json:"[  1,2,3,4,[  5,6,7,[  8,9,10  ],11,12  ]  ]", opts:{arrayPadding:2} },
		{ json:"[1, 2, 3, 4, [5, 6, 7, [8, 9, 10], 11, 12]]", opts:{afterComma:1} },
		{ json:"[ 1, 2, 3, 4, [ 5, 6, 7, [ 8, 9, 10 ], 11, 12 ] ]", opts:{afterComma:1,arrayPadding:1} },
		{ json:"[1,\n 2,\n 3,\n 4,\n [5,\n  6,\n  7,\n  [8,\n   9,\n   10],\n  11,\n  12]]", opts:{short:true,wrap:true} },
		{ json:"[1,\n 2,\n 3,\n 4,\n [5,\n  6,\n  7,\n  [8,\n   9,\n   10],\n  11,\n  12]]", opts:{short:true,wrap:true,afterComma:1} },
		{ json:"[ 1,\n  2,\n  3,\n  4,\n  [ 5,\n    6,\n    7,\n    [ 8,\n      9,\n      10 ],\n    11,\n    12 ] ]", opts:{short:true,wrap:true,arrayPadding:1} },
	]},

	{value:[1,2,3], tests:[
		{ json:"[1,2,3]" },
		{ json:"[1 ,2 ,3]",   opts:{beforeComma:1} },
		{ json:"[1 , 2 , 3]", opts:{aroundComma:1} },
		{ json:"[\n\t1,\n\t2,\n\t3\n]",   opts:{wrap:true,indent:"\t"} },
		{ json:"[\n\t1,\n\t2,\n\t3\n\t]", opts:{wrap:true,indent:"\t",indentLast:true} },
	]},

	{value:{b:1,a:2}, tests:[
		{ json:'{"b":1,"a":2}' },
		{ json:'{"a":2,"b":1}',              opts:{sorted:true} },
		{ json:'{"a":2,"b":1}',              opts:{sort:true}   },
		{ json:'{"a":2, "b":1}',             opts:{sorted:true,afterComma:1} },
		{ json:'{"a" :2,"b" :1}',            opts:{sorted:true,beforeColon:1} },
		{ json:'{"a": 2,"b": 1}',            opts:{sorted:true,afterColon:1} },
		{ json:'{"a" : 2,"b" : 1}',          opts:{sorted:true,beforeColon:1,afterColon:1} },
		{ json:'{"a" : 2, "b" : 1}',         opts:{sorted:true,beforeColon:1,afterColon:1,afterComma:1} },
		{ json:'{ "a" : 2, "b" : 1 }',       opts:{sorted:true,beforeColon:1,afterColon:1,afterComma:1,padding:1} },
		{ json:'{ "a" : 2, "b" : 1 }',       opts:{sorted:true,aroundColon:1,afterComma:1,objectPadding:1} },
		{ json:'{"a" : 2, "b" : 1}',         opts:{sorted:true,beforeColon:1,afterColon:1,afterComma:1,arrayPadding:1} },
		{ json:'{  "a"  :  2, "b"  :  1  }', opts:{sorted:true,aroundColon:2,afterComma:1,padding:2} },
		{ json:'{  "a":2, "b":1  }',         opts:{sorted:true,afterComma:1,padding:2} },
		{ json:'{"b":  1,"a":  2}',               opts:{afterColon1:2} },
		{ json:'{"b"  :  1,"a"  :  2}',           opts:{aroundColon1:2} },
		{ json:"{\n  \"b\":1,\n  \"a\":2\n}",     opts:{wrap:true,aroundColon1:2} },
		{ json:"{\n  \"b\": 1,\n  \"a\": 2\n}",   opts:{wrap:true,afterColon:1} },
		{ json:"{\n  \"b\": 1,\n  \"a\": 2\n}",   opts:{wrap:true,afterColonN:1} },
		{ json:"{\"b\":1,\n \"a\":2}",            opts:{wrap:true,short:true} },
		{ json:"{\"b\": 1,\n \"a\": 2}",          opts:{wrap:true,short:true,afterColon:1} },
		{ json:"{\"b\": 1,\n \"a\": 2}",          opts:{wrap:true,short:true,afterColonN:1} },
		{ json:"{\"b\":1,\n \"a\":2}",            opts:{wrap:true,short:true,afterColon1:1} },
	]},

	{value:{b:1,aaa:2,cc:3}, tests:[
		{ json:"{\n  \"b\":1,\n  \"aaa\":2,\n  \"cc\":3\n}",    opts:{wrap:true} },
		{ json:"{\n  \"b\"  :1,\n  \"aaa\":2,\n  \"cc\" :3\n}", opts:{wrap:true,aligned:true} },
		{ json:"{\"b\":1,\"aaa\":2,\"cc\":3}",                  opts:{aligned:true} },
		{ json:"{\n  \"aaa\":2,\n  \"b\"  :1,\n  \"cc\" :3\n}", opts:{wrap:true,aligned:true,sorted:true} },
	]},

	{value:{a:1}, tests:[
		{ json:'{"a":1}' },
		{ json:"{\n  \"a\":1\n}",   opts:{wrap:true} },
		{ json:"{\n  \"a\":1\n  }", opts:{wrap:true, indentLast:true} },
		{ json:"{\n \"a\":1\n }",   opts:{wrap:true, indentLast:true, indent:" " } },
	]},

	{value:{ b:17, a:42 }, tests:[
		{ json:"{\"a\":42,\n \"b\":17}", opts:{wrap:10,sorted:true,short:true} },
		{ json:"{\"a\":42,\n \"b\":17}", opts:{wrap:10,sort:true,  short:true} },
		{ json:"{\n  \"a\":42,\n  \"b\":17\n}", opts:{wrap:1,sorted:true} },
		{ json:"{\n  \"a\":42,\n  \"b\":17\n}", opts:{wrap:1,sort:true} },
		{ json:"{\"a\":42,\"b\":17}",    opts:{wrap:false,sort:function(k){     return k              } } },
		{ json:"{\"b\":17,\"a\":42}",    opts:{wrap:false,sort:function(k,v){   return v              } } },
		{ json:"{\"a\":42,\"b\":17}",    opts:{wrap:false,sort:function(k,v){   return -v             } } },
		{ json:"{\"a\":42,\"b\":17}",    opts:{wrap:false,sort:function(k,v,o){ return v==o.a ? 0 : 1 } } },
		{ json:"{\n\"b\":17,\n\"a\":42\n}", opts:{wrap:1,indent:"",sort:function(k){ return k=="a" ? 1 : 0 } } },
		{ json:"{\n\"a\":42,\n\"b\":17\n}", opts:{wrap:1,indent:"",sort:function(k){ return k=="a" ? 0 : 1 } } },
	]},

	{value:[1,{a:2},3], tests:[
		{ json:'[1,{"a":2},3]' },
		{ json:'[ 1,{ "a":2 },3 ]',                           opts:{padding:1} },
		{ json:'[ 1, { "a":2 }, 3 ]',                         opts:{padding:1,afterComma:1} },
		{ json:"[\n  1,\n  {\n    \"a\":2\n  },\n  3\n]",     opts:{wrap:true} },
		{ json:"[\n  1,\n  {\"a\":2},\n  3\n]",               opts:{wrap:10} },
		{ json:"[\n  1,\n  {\n    \"a\":2\n    },\n  3\n  ]", opts:{wrap:true,indentLast:true} },
	]},

	{value:[1,{a:2,b:3},4], tests:[
		{ json:"[1,\n {\"a\":2,\n  \"b\":3},\n 4]", opts:{wrap:0,short:true} },
	]},

	{value:{a:1,b:[2,3,4],c:3}, tests:[
		{ json:'{"a":1,"b":[2,3,4],"c":3}' },
		{ json:"{\n  \"a\":1,\n  \"b\":[2,3,4],\n  \"c\":3\n}",                           opts:{wrap:10} },
		{ json:"{\n  \"a\":1,\n  \"b\":[\n    2,\n    3,\n    4\n  ],\n  \"c\":3\n}",     opts:{wrap:true} },
		{ json:"{\n  \"a\":1,\n  \"b\":[\n    2,\n    3,\n    4\n    ],\n  \"c\":3\n  }", opts:{wrap:true,indentLast:true} },
	]},

	{value:{hooo:42,whee:['yaaa','oooo','booy'],zoop:"whoop"}, tests:[
		{ json:"{\"hooo\":42,\n \"whee\":[\"yaaa\",\n         \"oooo\",\n         \"booy\"],\n \"zoop\":\"whoop\"}", opts:{wrap:20,short:true} },
	]},

	{value:{ a:[ {x:"foo",y:"jim"}, {x:"bar",y:"jam"} ] }, tests:[
		{ json:"{\"a\":[{\"x\":\"foo\",\n       \"y\":\"jim\"},\n      {\"x\":\"bar\",\n       \"y\":\"jam\"}]}", opts:{wrap:true,short:true} },
	]},

	{value:{"abcdefghij":[{"abcdefghijklmnop":{}}]}, tests:[
		{ json:'{"abcdefghij":[{"abcdefghijklmnop":{}}]}' },
		{ json:'{"abcdefghij" : [{"abcdefghijklmnop" : {}}]}', opts:{wrap:1, short:true, aroundColonN:1} },
	]},

	{value:{"foo":{}}, tests:[
		{ json:'{"foo":{}}' },
		{ json:'{"foo":{}}',        opts:{wrap:false} },
		{ json:'{\n  "foo":{}\n}',  opts:{wrap:5}    },
		{ json:'{"foo":{}}',        opts:{wrap:1, short:true} },
	]},

	{value:["foo",{},"bar"], tests:[
		{ json:'[\n  "foo",\n  {},\n  "bar"\n]',  opts:{wrap:1} },
		{ json:'["foo",\n {},\n "bar"]',          opts:{wrap:1, short:true} },
	]},

	{value:["foo",[],"bar"], tests:[
		{ json:'[\n  "foo",\n  [],\n  "bar"\n]',  opts:{wrap:1} },
		{ json:'["foo",\n [],\n "bar"]',          opts:{wrap:1, short:true} },
	]},

	{value:["foo",[{},[{"foo":[]},42]],"bar"], tests:[
		{ json:'["foo",\n [{},\n  [{"foo":[]},\n   42]],\n "bar"]',  opts:{wrap:1, short:true} },
	]},

	{value:{a:{b:{c:{d:{e:{f:{g:{h:{i:{j:{k:{l:{m:1}}}}}}}}}}}}}, tests:[
		{ json:'{"a":{"b":{"c":{"d":{"e":{"f":{"g":{"h":{"i":{"j":{"k":{"l":{"m":1}}}}}}}}}}}}}', opts:{wrap:false} },
		{ json:'{"a":{"b":{"c":{"d":{"e":{"f":{"g":{"h":{"i":{"j":{"k":{"l":{"m":1}}}}}}}}}}}}}', opts:{wrap:1,short:true} },
		{ json:"{\n  \"a\":{\n    \"b\":{\n      \"c\":{\n        \"d\":{\n          \"e\":{\n            \"f\":{\n              \"g\":{\n                \"h\":{\n                  \"i\":{\n                    \"j\":{\n                      \"k\":{\n                        \"l\":{\n                          \"m\":1\n                        }\n                      }\n                    }\n                  }\n                }\n              }\n            }\n          }\n        }\n      }\n    }\n  }\n}", opts:{wrap:1} },
	]},

	{value:{inf:1/0, neginf:-1/0, nan:0/0}, tests:[
		{ json:'{"inf":9e9999,"nan":"NaN","neginf":-9e9999}', opts:{sort:true} },
	]},

	{value:[0, 1, 1.1, 1.555555], tests:[
		{ json:'[0,1,1.1,1.555555]', opts:{forceFloats:false} },
		{ json:'[0.0,1.0,1.1,1.555555]', opts:{forceFloats:true} },
		{ json:'[0.000,1.000,1.100,1.556]', opts:{forceFloats:true, decimals:3} },
		{ json:'[0.0,1.0,1.1,1.556]', opts:{forceFloats:true, decimals:3, trimTrailingZeros:true} },
		{ json:'[0,1,1.1,1.556]', opts:{forceFloats:false, decimals:3, trimTrailingZeros:true} },
	]},

	{value:{floats:[0, 1, 0.1, 1.555555], raw:[0, 1, 0.1, 1.555555]}, tests:[
		{ json:'{"floats":[0,1,0.1,1.555555],"raw":[0,1,0.1,1.555555]}', opts:{forceFloats:false} },
		{ json:'{"floats":[0.0,1.0,0.1,1.555555],"raw":[0.0,1.0,0.1,1.555555]}', opts:{forceFloats:true} },
		{ json:'{"floats":[0.0,1.0,0.1,1.555555],"raw":[0,1,0.1,1.555555]}', opts:{forceFloatsIn:['floats']} },

		{ json:'{"floats":[0,1,0.100,1.556],"raw":[0,1,0.100,1.556]}', opts:{forceFloats:false, decimals:3} },
		{ json:'{"floats":[0.000,1.000,0.100,1.556],"raw":[0.000,1.000,0.100,1.556]}', opts:{forceFloats:true, decimals:3} },
		{ json:'{"floats":[0.000,1.000,0.100,1.556],"raw":[0,1,0.100,1.556]}', opts:{forceFloatsIn:['floats'], decimals:3} },

		{ json:'{"floats":[0,1,0.1,1.556],"raw":[0,1,0.1,1.556]}', opts:{forceFloats:false, decimals:3, trimTrailingZeros:true} },
		{ json:'{"floats":[0.0,1.0,0.1,1.556],"raw":[0.0,1.0,0.1,1.556]}', opts:{forceFloats:true, decimals:3, trimTrailingZeros:true} },
		{ json:'{"floats":[0.0,1.0,0.1,1.556],"raw":[0,1,0.1,1.556]}', opts:{forceFloatsIn:['floats'], decimals:3, trimTrailingZeros:true} },
	]},

	{value:[1,2,3,{a:[4,5,{a:6, b:7}], b:[8,9,{a:10, b:11}]}], tests:[
		{ json:'[1,2,3,{"a":[4,5,{"a":6,"b":7}],"b":[8,9,{"a":10,"b":11}]}]', opts:{} },
		{ json:'[1.0,2.0,3.0,{"a":[4.0,5.0,{"a":6.0,"b":7.0}],"b":[8.0,9.0,{"a":10.0,"b":11.0}]}]', opts:{forceFloats:true, wrap:false} },
		{ json:'[1,2,3,{"a":[4.0,5.0,{"a":6.0,"b":7}],"b":[8,9,{"a":10.0,"b":11}]}]', opts:{forceFloatsIn:['a'], wrap:false} },
	]},

	{value:[1,2,3, {bar:[4,5,6], foo:[7,8,9]}], tests:[
		{ json:'[\n\t1,\n\t2,\n\t3,\n\t{\n\t\t"bar":[4,5,6],\n\t\t"foo":[7,8,9]\n\t}\n]', opts:{wrap:20, indent:"\t"} },
		{ json:'[\n\t1,\n\t2,\n\t3,\n\t{\n\t\t"bar":[4.0,5.0,6.0],\n\t\t"foo":[7,8,9]\n\t}\n]', opts:{wrap:20, indent:"\t", forceFloatsIn:['bar']} },
		{ json:'[\n\t1,\n\t2,\n\t3,\n\t{\n\t\t"bar":[4,5,6],\n\t\t"foo":[7.0,8.0,9.0]\n\t}\n]', opts:{wrap:20, indent:"\t", forceFloatsIn:['foo']} },
		{ json:'[\n\t1,\n\t2,\n\t3,\n\t{\n\t\t"bar":[4.0,5.0,6.0],\n\t\t"foo":[7.0,8.0,9.0]\n\t}\n]', opts:{wrap:20, indent:"\t", forceFloatsIn:['foo', 'bar']} },
		{ json:'[\n\t1.0,\n\t2.0,\n\t3.0,\n\t{\n\t\t"bar":[4.0,5.0,6.0],\n\t\t"foo":[7.0,8.0,9.0]\n\t}\n]', opts:{wrap:20, indent:"\t", forceFloats:true} },
	]},

	// Issue #32
	{value:[1,2], tests:[
		{ json:'[\n  1,\n  2\n]', opts:{wrap:true, decimals:3} },
		{ json:'[\n  1,\n  2\n]', opts:{wrap:true, decimals:3, trimTrailingZeros:true} },
	]},

	// Issue #33
	{value:[1,2], tests:[
		{ json:'[\n1,\n2\n]', opts:{wrap:true, indent:'', decimals:3, trimTrailingZeros:true} },
		{ json:'[1,\n 2]',    opts:{wrap:true, indent:'', decimals:3, trimTrailingZeros:true, short:true} },
	]},
]

