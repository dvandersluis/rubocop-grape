module RuboCop
  module Cop
    # Helper methods to deal with nodes that are sometimes begin nodes
    module BeginNodeHelp
      def any?(node)
        if node.begin_type?
          node.child_nodes.any? { |child| yield child }
        else
          yield node
        end
      end

      def all?(node)
        if node.begin_type?
          node.child_nodes.all? { |child| yield child }
        else
          yield node
        end
      end
    end
  end
end
