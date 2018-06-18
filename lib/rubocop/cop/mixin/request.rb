module RuboCop
  module Cop
    # Common functionality for dealing with request nodes
    module Request
      REQUEST_METHODS = %i(get post put head delete options patch).freeze

      extend NodePattern::Macros

      def_node_search :request?, <<-PATTERN
        (block (send nil? #request_method? ...) ...)
      PATTERN

      private

      def request_method?(sym)
        REQUEST_METHODS.include?(sym)
      end
    end
  end
end
