require 'json'
module JSON
	# Generate the JSON string representation for an object,
	# with a variety of formatting options.
	#
	# @author Gavin Kistner <!@phrogz.net>
	# @param object [Object] the object to serialize
	# @param opts [Hash] the formatting options
	# @option opts [Integer] :wrap            (80)    The maximum line width before wrapping. Use `false` to never wrap, or `true` to always wrap.
	# @option opts [String]  :indent          ("  ")  Whitespace used to indent each level when wrapping (without the :short option).
	# @option opts [Boolean] :indent_last     (false) Indent the closing bracket for arrays and objects (without the :short option).
	# @option opts [Boolean] :short           (false) Keep the output 'short' when wrapping, putting opening brackets on the same line as the first value, and closing brackets on the same line as the last item.
	# @option opts [Boolean] :sort            (false) Sort the keys for objects to be in alphabetical order (`true`), or supply a lambda to determine ordering.
	# @option opts [Boolean] :aligned         (false) When wrapping objects, align the colons (only per object).
	# @option opts [Boolean] :force_floats    (false) Ensure that all integer values have `.0` after them.
	# @option opts [Array]   :force_floats_in ([])    Array of object key names to force floats inside of.
	# @option opts [Integer] :decimals        (null) Decimal precision to use for floats; omit to keep numeric values precise.
	# @option opts [Boolean] :trim_trailing_zeros (false) Remove trailing zeros added by `decimals`` from the ends of floating point numbers.
	# @option opts [Integer] :padding         (0) Number of spaces to put inside brackets/braces for both arrays and objects.
	# @option opts [Integer] :array_padding   (0) Number of spaces to put inside brackets for arrays. Overrides `:padding`.
	# @option opts [Integer] :object_padding  (0) Number of spaces to put inside braces for objects. Overrides `:padding`.
	# @option opts [Integer] :around_comma    (0) Number of spaces to put before/after commas (for both arrays and objects).
	# @option opts [Integer] :before_comma    (0) Number of spaces to put before commas (for both arrays and objects).
	# @option opts [Integer] :after_comma     (0) Number of spaces to put after commas (for both arrays and objects).
	# @option opts [Integer] :around_colon    (0) Number of spaces to put before/after colons (for objects).
	# @option opts [Integer] :before_colon    (0) Number of spaces to put before colons (for objects).
	# @option opts [Integer] :after_colon     (0) Number of spaces to put after colons (for objects).
	# @option opts [Integer] :around_colon_1  (0) Number of spaces to put before/after colons for single-line objects.
	# @option opts [Integer] :before_colon_1  (0) Number of spaces to put before colons for single-line objects.
	# @option opts [Integer] :after_colon_1   (0) Number of spaces to put after colons for single-line objects.
	# @option opts [Integer] :around_colon_n  (0) Number of spaces to put before/after colons for multi-line objects.
	# @option opts [Integer] :before_colon_n  (0) Number of spaces to put before colons for multi-line objects.
	# @option opts [Integer] :after_colon_n   (0) Number of spaces to put after colons for multi-line objects.
	# @return [String] the JSON representation of the object.
	#
	# The lambda for the `sort` option will be passed the string name of the key, the value, and the hash for the object being sorted.
	# The values returned for all keys must be all comparable, or an error will occur.
	def self.neat_generate(object,opts={})
		opts ||= {}
		opts[:wrap] = 80 unless opts.key?(:wrap)
		opts[:wrap] = -1 if opts[:wrap]==true
		opts[:indent]         ||= "  "
		opts[:force_floats_in]||= []
		opts[:array_padding]  ||= opts[:padding]      || 0
		opts[:object_padding] ||= opts[:padding]      || 0
		opts[:after_comma]    ||= opts[:around_comma] || 0
		opts[:before_comma]   ||= opts[:around_comma] || 0
		opts[:before_colon]   ||= opts[:around_colon] || 0
		opts[:after_colon]    ||= opts[:around_colon] || 0
		opts[:before_colon_1] ||= opts[:around_colon_1] || opts[:before_colon] || 0
		opts[:after_colon_1]  ||= opts[:around_colon_1] || opts[:after_colon]  || 0
		opts[:before_colon_n] ||= opts[:around_colon_n] || opts[:before_colon] || 0
		opts[:after_colon_n]  ||= opts[:around_colon_n] || opts[:after_colon]  || 0
		raise ":indent option must only be whitespace" if opts[:indent]=~/\S/

		apad  = " " * opts[:array_padding]
		opad  = " " * opts[:object_padding]
		comma = "#{' '*opts[:before_comma]},#{' '*opts[:after_comma]}"
		colon1= "#{' '*opts[:before_colon_1]}:#{' '*opts[:after_colon_1]}"
		colonn= "#{' '*opts[:before_colon_n]}:#{' '*opts[:after_colon_n]}"

		memoizer = {}
		build = ->(o,indent,floats_forced) do
			memoizer[[o,indent,floats_forced]] ||= case o
				when String               then "#{indent}#{self.generate(o)}"
				when Symbol               then "#{indent}#{self.generate(o.to_s)}"
				when TrueClass,FalseClass then "#{indent}#{o}"
				when NilClass             then "#{indent}null"
				when Integer
					floats_forced ? build[o.to_f, indent, floats_forced] : "#{indent}#{o.inspect}"
				when Float
					if o.infinite?
						"#{indent}#{o<0 ? "-9e9999" : "9e9999"}"
					elsif o.nan?
						"#{indent}\"NaN\""
					elsif !floats_forced && (o==o.to_i) && (o.to_s !~ /e/)
						build[o.to_i, indent, floats_forced]
					elsif opts[:decimals]
						if opts[:trim_trailing_zeros]
							"#{indent}#{o.round(opts[:decimals])}"
						else
							"#{indent}%.#{opts[:decimals]}f" % o
						end
					else
						"#{indent}#{o}"
					end

				when Array
					if o.empty?
						"#{indent}[]"
					else
						pieces = o.map{ |v| build[v, '', floats_forced] }
						one_line = "#{indent}[#{apad}#{pieces.join comma}#{apad}]"
						if !opts[:wrap] || (one_line.length <= opts[:wrap])
							one_line
						elsif opts[:short]
							indent2 = "#{indent} #{apad}"
							pieces = o.map{ |v| build[v, indent2, floats_forced] }
							pieces[0] = pieces[0].sub indent2, "#{indent}[#{apad}"
							pieces[pieces.length-1] = "#{pieces.last}#{apad}]"
							pieces.join ",\n"
						else
							indent2 = "#{indent}#{opts[:indent]}"
							"#{indent}[\n#{o.map{ |v| build[v, indent2, floats_forced] }.join ",\n"}\n#{opts[:indent_last] ? indent2 : indent}]"
						end
					end

				when Hash
					if o.empty?
						"#{indent}{}"
					else
						case sort=(opts[:sorted] || opts[:sort])
							when true then o = o.sort_by{|k,v| k.to_s }
							when Proc
								o = case sort.arity
								when 1 then o.sort_by{ |k,v| sort[k] }
								when 2 then o.sort_by{ |k,v| sort[k,v] }
								when 3 then o.sort_by{ |k,v| sort[k,v,o] }
								end
						end
						keys = o.map{ |x| x.first.to_s }
						keyvals = o.map.with_index{ |(k,v),i| [ self.generate(k.to_s), build[v, '', opts[:force_floats] || opts[:force_floats_in].include?(keys[i])] ] }
						keyvals = keyvals.map{ |kv| kv.join(colon1) }.join(comma)
						one_line = "#{indent}{#{opad}#{keyvals}#{opad}}"
						if !opts[:wrap] || (one_line.length <= opts[:wrap])
							one_line
						else
							if opts[:short]
								keyvals = o.map{ |k,v| ["#{indent} #{opad}#{self.generate(k.to_s)}",v] }
								keyvals[0][0] = keyvals[0][0].sub "#{indent} ", "#{indent}{"
								if opts[:aligned]
									longest = keyvals.map(&:first).map(&:length).max
									formatk = "%-#{longest}s"
									keyvals.map!{ |k,v| [ formatk % k,v] }
								end
								keyvals.map!.with_index do |(k,v),i|
									floats_forced = opts[:force_floats] || opts[:force_floats_in].include?(keys[i])
									indent2 = " "*"#{k}#{colonn}".length
									one_line = "#{k}#{colonn}#{build[v, '', floats_forced]}"
									if opts[:wrap] && (one_line.length > opts[:wrap]) && (v.is_a?(Array) || v.is_a?(Hash))
										"#{k}#{colonn}#{build[v, indent2, floats_forced].lstrip}"
									else
										one_line
									end
								end
								"#{keyvals.join(",\n")}#{opad}}"
							else
								keyvals = o.map{ |k,v| ["#{indent}#{opts[:indent]}#{self.generate(k.to_s)}",v] }
								if opts[:aligned]
									longest = keyvals.map(&:first).map(&:length).max
									formatk = "%-#{longest}s"
									keyvals.map!{ |k,v| [ formatk % k,v] }
								end
								indent2 = "#{indent}#{opts[:indent]}"
								keyvals.map!.with_index do |(k,v),i|
									floats_forced = opts[:force_floats] || opts[:force_floats_in].include?(keys[i])
									one_line = "#{k}#{colonn}#{build[v, '', floats_forced]}"
									if opts[:wrap] && (one_line.length > opts[:wrap]) && (v.is_a?(Array) || v.is_a?(Hash))
										"#{k}#{colonn}#{build[v, indent2, floats_forced].lstrip}"
									else
										one_line
									end
								end
								"#{indent}{\n#{keyvals.join(",\n")}\n#{opts[:indent_last] ? indent2 : indent}}"
							end
						end
					end

				else
					"#{indent}#{o.to_json(opts)}"
			end
		end

		build[object, '', opts[:force_floats]]
	end
end
