require 'rubocop'
require 'rubocop/grape'
require 'rubocop/grape/inject'

RuboCop::Grape::Inject.defaults!

require 'rubocop/cop/grape/empty_request_path'
require 'rubocop/cop/grape/status_no_content'
