module RuboCop
  module Cop
    # Corrector to move a node to the top of another node it is a descendant of
    class MoveToTopCorrector
      include RangeHelp

      attr_reader :node, :processed_source, :first_child

      def initialize(node, parent, processed_source)
        @processed_source = processed_source
        @node = node
        @first_child = parent.child_nodes.first
      end

      def correct
        lambda do |corrector|
          corrector.replace(range, "\n#{indentation(node.parent)}")
          corrector.insert_before(first_child.loc.expression.begin, corrected_source)
        end
      end

      private

      def indentation(node)
        ' '.freeze * column(node)
      end

      def column(node)
        node.loc.expression.column
      end

      def corrected_source
        "#{correct_indentation}\n\n#{indentation(first_child)}"
      end

      def correct_indentation
        node_indentation = column(node)
        actual_indentation = column(first_child)

        lines = node.source.split("\n")
        lines.each { |line| line.gsub!(/\A\s{#{node_indentation - actual_indentation}}/, '') }
        lines.join("\n")
      end

      def range
        range_with_surrounding_space(range: node.loc.expression, whitespace: true)
      end
    end
  end
end
