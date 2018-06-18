module RuboCop
  module Cop
    module Grape
      # This cop identifies places where `status :no_content` or `status 204` should
      # be replaced with `body false`.
      #
      # There is a bug in grape that setting `status :no_content` without a body will
      # cause requests to not complete in certain situations (such as in curl),
      # however `body false` will also set a `204 No Content` response status.
      #
      # @example
      #
      #   # bad
      #   status :no_content
      #
      #   # bad
      #   status 204
      #
      #   # good
      #   body false
      class StatusNoContent < Cop
        MSG = 'Use `body false` instead of `%<param>s`.'.freeze

        def_node_matcher :status_no_content?, <<-PATTERN
          (send nil? :status {(sym :no_content) (int 204)})
        PATTERN

        def on_send(node)
          return unless status_no_content?(node)
          add_offense(node)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.expression, 'body false')
          end
        end

        def message(send_node)
          format(MSG, param: send_node.source)
        end
      end
    end
  end
end
