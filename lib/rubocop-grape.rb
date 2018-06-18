require 'rubocop'
require 'rubocop/grape'
require 'rubocop/grape/inject'

RuboCop::Grape::Inject.defaults!

require 'rubocop/cop/correctors/move_to_top_corrector'

require 'rubocop/cop/mixin/begin_node_help'
require 'rubocop/cop/mixin/grape_api_help'
require 'rubocop/cop/mixin/request'

require 'rubocop/cop/grape/empty_request_path'
require 'rubocop/cop/grape/missing_desc'
require 'rubocop/cop/grape/status_no_content'
