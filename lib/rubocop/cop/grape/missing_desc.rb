module RuboCop
  module Cop
    module Grape
      # This cop identifies `Grape::API` subclasses that don't have a description. Every API
      # method should have a description so that consumers can know how to use it.
      #
      # Supports autocorrect only for descriptions in the wrong location (if TopLevel is true).
      #
      # @example
      #
      #   # bad
      #   class MyEndpoint < Grape::API
      #     post do
      #       # ...
      #     end
      #   end
      #
      #   # good
      #   class MyEndpoint < Grape::API
      #     desc 'This is my endpoint'
      #
      #     post do
      #       # ...
      #     end
      #   end
      #
      #   # good
      #   class MyEndpoint < Grape::API
      #     desc 'This is my endpoint' do
      #       detail 'more detail'
      #     end
      #
      #     post do
      #       # ...
      #     end
      #   end
      #
      # @example TopLevel: true (default)
      #
      #   # bad
      #   class MyEndpoint < Grape::API
      #     route_param :id do
      #       desc 'Description'
      #
      #       post do
      #         # ...
      #       end
      #     end
      #   end
      #
      #   # good
      #   class MyEndpoint < Grape::API
      #     desc 'Description'
      #
      #     route_param :id do
      #       post do
      #         # ...
      #       end
      #     end
      #   end
      #
      # @example TopLevel: false
      #
      #   # good
      #   class MyEndpoint < Grape::API
      #     route_param :id do
      #       desc 'Description'
      #
      #       post do
      #         # ...
      #       end
      #     end
      #   end
      #
      #   # good
      #   class MyEndpoint < Grape::API
      #     desc 'Description'
      #
      #     route_param :id do
      #       post do
      #         # ...
      #       end
      #     end
      #   end
      #
      # @example RequiredForResources: true (default)
      #
      #   # bad
      #   class MyEndpoint < Grape::API
      #     mount Foo
      #     mount Bar
      #   end
      #
      #   # bad
      #   class MyResource < Grape::API
      #     resource :my_resource do
      #       mount Foo
      #     end
      #   end
      #
      #   # good
      #   class MyEndpoint < Grape::API
      #     desc 'This is my resource'
      #
      #     mount Foo
      #     mount Bar
      #   end
      #
      #   # good
      #   class MyResource < Grape::API
      #     desc 'This is my resource'
      #
      #     resource :my_resource do
      #       mount Foo
      #     end
      #   end
      #
      # @example RequiredForResources: false
      #
      #   # bad
      #   class MyEndpoint < Grape::API
      #     mount Foo
      #     mount Bar
      #
      #     post do
      #       # ...
      #     end
      #   end
      #
      #   # bad
      #   class MyEndpoint < Grape::API
      #     resource :my_resource do
      #       mount Foo
      #       mount Bar
      #
      #       post do
      #         # ...
      #       end
      #     end
      #   end
      #
      #   # good
      #   class MyEndpoint < Grape::API
      #     mount Foo
      #     mount Bar
      #   end
      #
      #   # good
      #   class MyResource < Grape::API
      #     resource :my_resource do
      #       mount Foo
      #     end
      #   end
      class MissingDesc < Cop
        include BeginNodeHelp
        include GrapeAPIHelp

        MSG = 'Grape API classes must have a `desc`.'.freeze
        TOP_LEVEL_MSG = '`desc` must not be placed within a block.'.freeze
        EMPTY_STRING_MSG = '`desc` must be given a non-empty string.'.freeze

        def_node_matcher :desc?, <<-PATTERN
          {(send nil? :desc) (send nil? :desc _)}
        PATTERN

        def_node_matcher :block_desc?, <<-PATTERN
          (block #desc? ...)
        PATTERN

        def_node_matcher :top_level_desc?, <<-PATTERN
          {#desc? #block_desc?}
        PATTERN

        def_node_search :desc, <<-PATTERN
          #desc?
        PATTERN

        def_node_search :block_desc, <<-PATTERN
          #block_desc?
        PATTERN

        def_node_search :mount?, <<-PATTERN
          (send nil? :mount ...)
        PATTERN

        # Only misplaced `desc`s can be autocorrected
        def autocorrect(node)
          *, body = *node
          description = block_desc(body).first || desc(body).first
          return unless description

          MoveToTopCorrector.new(description, body, processed_source).correct
        end

        private

        def investigate(node, body)
          return if allowed_resource?(body)

          desc_node = desc_node(body)

          if desc_node.nil?
            add_offense(node)
          elsif empty_string?(desc_node)
            add_offense(node, location: desc_node.loc.expression, message: EMPTY_STRING_MSG)
          elsif top_level? && nested_desc?(body)
            add_offense(node, location: desc_node.loc.expression, message: TOP_LEVEL_MSG)
          end
        end

        def required_for_resources?
          cop_config['RequiredForResources']
        end

        def top_level?
          cop_config['TopLevel']
        end

        def desc_node(body)
          body ? desc(body).first : nil
        end

        def empty_string?(description)
          description.arguments.none? || description.arguments.first.str_content.empty?
        end

        def nested_desc?(body)
          return false if any?(body) { |node| top_level_desc?(node) }
          desc(body).any?
        end

        def allowed_resource?(body)
          return false if required_for_resources?
          resource_class?(body)
        end

        # A resource is an endpoint that only contains mounts, and no requests
        def resource_class?(body)
          return false unless body
          body = body.child_nodes.last if namespace?(body)

          return false if request?(body)
          mount?(body)
        end
      end
    end
  end
end
