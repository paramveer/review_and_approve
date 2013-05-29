module ReviewAndApprove
  module HashDiff
    def diff(orig, other)
      (orig.keys + other.keys).uniq.inject({}) do |memo, key|
        unless orig[key] == other[key]
          if orig[key].kind_of?(Hash) &&  other[key].kind_of?(Hash)
            memo[key] = ReviewAndApprove::HashDiff.diff(orig[key], other[key])
          else
            memo[key] = [orig[key], other[key]] 
          end
        end
        memo
      end
    end

    module_function :diff
  end
end