# frozen_string_literal: true

require_relative 'action_dispatch/session/dynamo_db_store'

module Aws
  module ActionDispatch
    module DynamoDb
      VERSION = File.read(File.expand_path('../VERSION', __dir__)).strip

      class Railtie < ::Rails::Railtie
        rake_tasks do
          load 'tasks/dynamo_db/session_store.rake'
        end
      end
    end
  end
end
