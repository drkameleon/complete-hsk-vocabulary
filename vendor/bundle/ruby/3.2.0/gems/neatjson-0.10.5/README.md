# NeatJSON

[![Gem Version](https://badge.fury.io/rb/neatjson.svg)](http://badge.fury.io/rb/neatjson)
[![Gem Downloads](http://ruby-gem-downloads-badge.herokuapp.com/neatjson?type=total&color=brightgreen)](https://rubygems.org/gems/neatjson)

Pretty-print your JSON in Ruby or JavaScript or Lua with more power than is provided by `JSON.pretty_generate` (Ruby) or `JSON.stringify` (JS). For example, like Ruby's `pp` (pretty print), NeatJSON can keep objects on one line if they fit, but break them over multiple lines if needed.

**Features:**

* [Online webpage](http://phrogz.net/JS/NeatJSON) for performing conversions and experimenting with options.
  * _Modifying graphical options on the webpage also gives you the JS code you would need to call to get the same results._
* Keep multiple values on one line, with variable wrap width.
* Format numeric values to specified decimal precision.
  * Optionally force specific keys to use floating point representation instead of bare integers for whole number values (e.g. `42.0` instead of `42`).
* Sort object keys to be in alphabetical order.
* Arbitrary whitespace (or really, any string) for indentation.
* "Short" wrapping uses fewer lines, indentation based on values. (See last example below.)
* Indent final closing bracket/brace for each array/object.
* Adjust number of spaces inside array/object braces.
* Adjust number of spaces before/after commas and colons (both for single- vs. multi-line).
* Line up the values for an object across lines.
* [Lua only] Produce Lua table serialization.


## Table of Contents

* [Installation](#installation)
* [Usage](#usage)
* [Examples](#examples)
* [Options](#options)
* [License & Contact](#license--contact)
* [TODO (aka Known Limitations)](#todo-aka-known-limitations)
* [History](#history)


## Installation

* Ruby: `gem install neatjson`
* JavaScript (web): Clone the GitHub repo and copy `javascript/neatjson.js`
* Node.js: `npm install neatjson`


## Usage

**Ruby**:

~~~ ruby
require 'neatjson'
json = JSON.neat_generate( value, options )
~~~


**JavaScript (web)**:

~~~ html
<script type="text/javascript" src="neatjson.js"></script>
<script type="text/javascript">
    var json = neatJSON( value, options );
</script>
~~~


**Node.js**:

~~~ js
const { neatJSON } = require('neatjson');
var json = neatJSON( value, options );
~~~


**Lua**:

~~~ lua
local neatJSON = require'neatjson'
local json = neatJSON(value, options)
~~~

## Examples

_The following are all in Ruby, but similar options apply in JavaScript and Lua._

~~~ ruby
require 'neatjson'

o = { b:42.005, a:[42,17], longer:true, str:"yes\nplease" }

puts JSON.neat_generate(o)
#=> {"b":42.005,"a":[42,17],"longer":true,"str":"yes\nplease"}

puts JSON.neat_generate(o, sort:true)
#=> {"a":[42,17],"b":42.005,"longer":true,"str":"yes\nplease"}

puts JSON.neat_generate(o,sort:true,padding:1,after_comma:1)
#=> { "a":[ 42, 17 ], "b":42.005, "longer":true, "str":"yes\nplease" }

puts JSON.neat_generate(o, sort:true, wrap:40)
#=> {
#=>   "a":[42,17],
#=>   "b":42.005,
#=>   "longer":true,
#=>   "str":"yes\nplease"
#=> }

puts JSON.neat_generate(o, sort:true, wrap:40, decimals:2)
#=> {
#=>   "a":[42,17],
#=>   "b":42.01,
#=>   "longer":true,
#=>   "str":"yes\nplease"
#=> }

puts JSON.neat_generate(o, sort:->(k){ k.length }, wrap:40, aligned:true)
#=> {
#=>   "a"     :[42,17],
#=>   "b"     :42.005,
#=>   "str"   :"yes\nplease",
#=>   "longer":true
#=> }

puts JSON.neat_generate(o, sort:true, wrap:40, aligned:true, around_colon:1)
#=> {
#=>   "a"      : [42,17],
#=>   "b"      : 42.005,
#=>   "longer" : true,
#=>   "str"    : "yes\nplease"
#=> }

puts JSON.neat_generate(o, sort:true, wrap:40, aligned:true, around_colon:1, short:true)
#=> {"a"      : [42,17],
#=>  "b"      : 42.005,
#=>  "longer" : true,
#=>  "str"    : "yes\nplease"}

a = [1,2,[3,4,[5]]]
puts JSON.neat_generate(a)
#=> [1,2,[3,4,[5]]]

puts JSON.pretty_generate(a) # oof!
#=> [
#=>   1,
#=>   2,
#=>   [
#=>     3,
#=>     4,
#=>     [
#=>       5
#=>     ]
#=>   ]
#=> ]

puts JSON.neat_generate( a, wrap:true, short:true )
#=> [1,
#=>  2,
#=>  [3,
#=>   4,
#=>   [5]]]

data = ["foo","bar",{dogs:42,piggies:{color:'pink', tasty:true},
        barn:{jimmy:[1,2,3,4,5],jammy:3.141592653,hot:"pajammy"},cats:7}]

opts = { short:true, wrap:60, decimals:3, sort:true, aligned:true,
         padding:1, after_comma:1, around_colon_n:1 }

puts JSON.neat_generate( data, opts )
#=> [ "foo",
#=>   "bar",
#=>   { "barn"    : { "hot"   : "pajammy",
#=>                   "jammy" : 3.142,
#=>                   "jimmy" : [ 1, 2, 3, 4, 5 ] },
#=>     "cats"    : 7,
#=>     "dogs"    : 42,
#=>     "piggies" : { "color":"pink", "tasty":true } } ]
~~~


## Options
You may pass any of the following options to `neat_generate` (Ruby) or `neatJSON` (JavaScript/Lua). **Note**: option names with underscores below use camelCase in JavaScript and Lua. For example:

~~~ ruby
# Ruby
json = JSON.neat_generate my_value, array_padding:1, after_comma:1, before_colon_n:2
~~~

~~~ js
// JavaScript
var json = neatJSON( myValue, { arrayPadding:1, afterComma:1, beforeColonN:2 } );
~~~

~~~ lua
-- Lua
local json = neatJSON( myValue, { arrayPadding=1, afterComma=1, beforeColonN=2 } )
~~~

* `wrap`                — Maximum line width before wrapping. Use `false` to never wrap, `true` to always wrap. default:`80`
* `indent`              — Whitespace used to indent each level when wrapping. default:`"  "` (two spaces)
* `indent_last`         — Indent the closing bracket/brace for arrays and objects? default:`false`
* `short`               — Put opening brackets on the same line as the first value, closing brackets on the same line as the last? default:`false`
  * _This causes the `indent` and `indent_last` options to be ignored, instead basing indentation on array and object padding._
* `sort`                — Sort objects' keys in alphabetical order (`true`), or supply a lambda for custom sorting. default:`false`
  * If you supply a lambda to the `sort` option, it will be passed three values: the (string) name of the key, the associated value, and the object being sorted, e.g. `{ sort:->(key,value,hash){ Float(value) rescue Float::MAX } }`
* `aligned`             — When wrapping objects, line up the colons (per object)? default:`false`
* `decimals`            — Decimal precision for non-integer numbers; use `false` to keep values precise. default:`false`
* `trim_trailing_zeros` — Remove extra zeros at the end of floats, e.g. `1.2000` becomes `1.2`. default:`false`
* `force_floats`        — Force every integer value written to the file to be a float, e.g. `12` becomes `12.0`. default:`false`
* `force_floats_in`     — Specify an array of object key names under which all integer values are treated as floats.
  For example, serializing `{a:[1, 2, {a:3, b:4}], c:{a:5, d:6}` with `force_floats_in:['a']` would produce `{"a":[1.0, 2.0, {"a":3.0, "b":4}], "c":{"a":5.0, "d":6}}`.
* `array_padding`       — Number of spaces to put inside brackets for arrays. default:`0`
* `object_padding`      — Number of spaces to put inside braces for objects.  default:`0`
* `padding`             — Shorthand to set both `array_padding` and `object_padding`. default:`0`
* `before_comma`        — Number of spaces to put before commas (for both arrays and objects). default:`0`
* `after_comma`         — Number of spaces to put after commas (for both arrays and objects). default:`0`
* `around_comma`        — Shorthand to set both `before_comma` and `after_comma`. default:`0`
* `before_colon_1`      — Number of spaces before a colon when the object is on one line. default:`0`
* `after_colon_1`       — Number of spaces after a colon when the object is on one line. default:`0`
* `before_colon_n`      — Number of spaces before a colon when the object is on multiple lines. default:`0`
* `after_colon_n`       — Number of spaces after a colon when the object is on multiple lines. default:`0`
* `before_colon`        — Shorthand to set both `before_colon_1` and `before_colon_n`. default:`0`
* `after_colon`         — Shorthand to set both `after_colon_1` and `after_colon_n`. default:`0`
* `around_colon`        — Shorthand to set both `before_colon` and `after_colon`. default:`0`
* `lua`                 — (Lua only) Output a Lua table literal instead of JSON? default:`false`
* `emptyTablesAreObjects` — (Lua only) Should `{}` in Lua become a JSON object (`{}`) or JSON array (`[]`)? default:`false` (array)

You may omit the 'value' and/or 'object' parameters in your `sort` lambda if desired. For example:

~~~ ruby
# Ruby sorting examples
obj = {e:3, a:2, c:3, b:2, d:1, f:3}

JSON.neat_generate obj, sort:true                              # sort by key name
#=> {"a":2,"b":2,"c":3,"d":1,"e":3,"f":3}

JSON.neat_generate obj, sort:->(k){ k }                        # sort by key name (long way)
#=> {"a":2,"b":2,"c":3,"d":1,"e":3,"f":3}

JSON.neat_generate obj, sort:->(k,v){ [-v,k] }                 # sort by descending value, then by ascending key
#=> {"c":3,"e":3,"f":3,"a":2,"b":2,"d":1}

JSON.neat_generate obj, sort:->(k,v,h){ h.values.count(v) }    # sort by count of keys with same value
#=> {"d":1,"a":2,"b":2,"e":3,"c":3,"f":3}
~~~

~~~ js
// JavaScript sorting examples
var obj = {e:3, a:2, c:3, b:2, d:1, f:3};

neatJSON( obj, {sort:true} );                                              // sort by key name
// {"a":2,"b":2,"c":3,"d":1,"e":3,"f":3}

neatJSON( obj, { sort:function(k){ return k }} );                          // sort by key name (long way)
// {"a":2,"b":2,"c":3,"d":1,"e":3,"f":3}

neatJSON( obj, { sort:function(k,v){ return -v }} );                       // sort by descending value
// {"e":3,"c":3,"f":3,"a":2,"b":2,"d":1}

var countByValue = {};
for (var k in obj) countByValue[obj[k]] = (countByValue[obj[k]]||0) + 1;
neatJSON( obj, { sort:function(k,v){ return countByValue[v] } } );         // sort by count of same value
// {"d":1,"a":2,"b":2,"e":3,"c":3,"f":3}
~~~

_Note that the JavaScript and Lua versions of NeatJSON do not provide a mechanism for cascading sort in the same manner as Ruby._


## License & Contact

NeatJSON is copyright ©2015–2022 by Gavin Kistner and is released under
the [MIT License](http://www.opensource.org/licenses/mit-license.php).
See the LICENSE.txt file for more details.

For bugs or feature requests please open [issues on GitHub][1].
For other communication you can [email the author directly](mailto:!@phrogz.net?subject=NeatJSON).


## TODO (aka Known Limitations)

* Figure out the best way to play with custom objects that use `to_json` for their representation.
* Detect circular references.
* Possibly allow "JSON5" output (legal identifiers unquoted, etc.)


## History

* **v0.10.5** — November 17, 2022
  * Fix issue #21: Strings containing `#` get an invalid escape added (Ruby only)

* **v0.10.4** — November 17, 2022
  * Online tool shows input/output bytes

* **v0.10.2** — August 31, 2022
  * Fix bugs found in JavaScript version related to `trim_trailing_zeros`.

* **v0.10.1** — August 29, 2022
  * Fix bugs found when `force_floats_in` was combined with wrapping.
  * Update interactive HTML tool to support new features.

* **v0.10** — August 29, 2022
  * Add `force_floats` and `force_floats_in` to support serialization for non-standard parsers that differentiate between integers and floats.
  * Add `trim_trailing_zeros` option to convert the `decimals` output from e.g. `5.40000` to `5.4`.
  * Convert JavaScript version to require ECMAScript 6 for performance.

* **v0.9** — July 29, 2019
  * Add Lua version, serializing to both JSON and Lua table literals
  * All languages serialize Infinity/-Infinity to JSON as `9e9999` and `-9e9999`
  * All languages serialize NaN to JSON as `"NaN"`

* **v0.8.4** — May 3, 2018
  * Fix issue #27: Default sorting fails with on objects with mixed keys [Ruby only]
    * _Thanks Reid Beels_

* **v0.8.3** — February 20, 2017
  * Fix issue #25: Sorting keys on multi-line object **using function** does not work without "short" [JS only]
    * _Thanks Bernhard Weichel_

* **v0.8.2** — December 16th, 2016
  * Fix issue #22: Sorting keys on multi-line object does not work without "short" [JS only]
  * Update online interface to support tabs as well as spaces.
  * Update online interface to use a textarea for the output (easier to select and copy).
  * Update online interface turn off spell checking for input and output.

* **v0.8.1** — April 22nd, 2016
  * Make NeatJSON work with [Opal](http://opalrb.org) (by removing all in-place string mutations)

* **v0.8** — April 21st, 2016
  * Allow `sort` to take a lambda for customized sorting of object key/values.

* **v0.7.2** — April 14th, 2016
  * Fix JavaScript library to support objects without an `Object` constructor (e.g. `location`).
  * Online HTML converter accepts arbitrary JavaScript values as input in addition to JSON.

* **v0.7.1** — April 6th, 2016
  * Fix Ruby library to work around bug in Opal.

* **v0.7** — March 26th, 2016
  * Add `indentLast`/`indent_last` feature.

* **v0.6.2** — February 8th, 2016
  * Use memoization to avoid performance stalls when wrapping deeply-nested objects/arrays.
    _Thanks @chroche_

* **v0.6.1** — October 12th, 2015
  * Fix handling of nested empty objects and arrays. (Would cause a runtime error in many cases.)
    * _This change causes empty arrays in a tight wrapping scenario to appear on a single line where they would previously take up three lines._

* **v0.6** — April 26th, 2015
  * Added `before_colon_1` and `before_colon_n` to distinguish between single-line and multi-line objects.

* **v0.5** — April 19th, 2015
  * Do not format integers (or floats that equal their integer) using `decimals` option.
  * Make `neatJSON()` JavaScript available to Node.js as well as web browsers.
  * Add (Node-based) testing for the JavaScript version.

* **v0.4** — April 18th, 2015
  * Add JavaScript version with online runner.

* **v0.3.2** — April 16th, 2015
  * Force YARD to use Markdown for documentation.

* **v0.3.1** — April 16th, 2015
  * Remove some debugging code accidentally left in.

* **v0.3** — April 16th, 2015
  * Fix another bug with `short:true` and wrapping array values inside objects.

* **v0.2** — April 16th, 2015
  * Fix bug with `short:true` and wrapping values inside objects.

* **v0.1** — April 15th, 2015
  * Initial release.

[1]: https://github.com/Phrogz/NeatJSON/issues
