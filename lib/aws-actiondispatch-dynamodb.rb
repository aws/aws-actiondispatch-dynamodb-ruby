# frozen_string_literal: true

require_relative 'action_dispatch/session/dynamo_db_store'

module Aws
  module ActionDispatch
    module DynamoDb
      VERSION = File.read(File.expand_path('../VERSION', __dir__)).strip
    end
  end
end
