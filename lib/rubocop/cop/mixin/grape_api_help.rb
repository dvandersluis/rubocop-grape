require 'rubocop/cop/mixin/request'

module RuboCop
  module Cop
    # Classes that include this module just implement functions to determine
    # what is an offense and how to do auto-correction. They operate only within
    # a Grape::API subclass and do not register offenses elsewhere.
    module GrapeAPIHelp
      include Request

      NAMESPACE_METHODS = %i(namespace resource resources group segment).freeze

      extend NodePattern::Macros

      def_node_matcher :namespace?, <<-PATTERN
        (block (send nil? #namespace_method? ...) ...)
      PATTERN

      def on_class(node)
        _name, superclass, body = *node

        return unless grape_api?(superclass)

        investigate(node, body)
      end

      private

      def namespace_method?(sym)
        NAMESPACE_METHODS.include?(sym)
      end

      def grape_api?(superclass)
        superclass && superclass.source == 'Grape::API'
      end
    end
  end
end
