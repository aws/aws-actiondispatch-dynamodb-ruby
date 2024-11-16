# frozen_string_literal: true

require 'action_dispatch/middleware/session/abstract_store'
require 'aws-sessionstore-dynamodb'

module ActionDispatch
  module Session
    # Uses the DynamoDB Session Store implementation to create a class that
    # extends `ActionDispatch::Session`. Rails will create a `:dynamo_db_store`
    # configuration for `:session_store` from this class name.
    #
    # This class will use `Rails.application.secret_key_base` as the secret key
    # unless otherwise provided.
    #
    # Configuration can also be provided in YAML files from Rails config, either
    # in `config/dynamo_db_session_store.yml` or `config/dynamo_db_session_store/{Rails.env}.yml`.
    # Configuration files that are environment-specific will take precedence.
    #
    # @see https://docs.aws.amazon.com/sdk-for-ruby/aws-sessionstore-dynamodb/api/Aws/SessionStore/DynamoDB/Configuration.html
    class DynamoDbStore < ActionDispatch::Session::AbstractStore
      def initialize(app, options = {})
        Rails.logger.warn('** Dynamo DB Session Storage no longer lives in aws-sdk-rails. ' \
                          'To avoid disruption, please add aws-actiondispatch-dynamodb ~> 0 to your Gemfile to ' \
                          'enable this feature when upgrading to aws-sdk-rails ~> 5. **')
        options[:config_file] ||= config_file
        options[:secret_key] ||= Rails.application.secret_key_base
        @middleware = Aws::SessionStore::DynamoDB::RackMiddleware.new(app, options)
        config.dynamo_db_client.config.user_agent_frameworks << 'aws-actiondispatch-dynamodb'
        super
      end

      # @return [Aws::SessionStore::DynamoDB::Configuration]
      def config
        @middleware.config
      end

      private

      # Required by `ActionDispatch::Session::AbstractStore`
      def find_session(req, sid)
        @middleware.find_session(req, sid)
      end

      # Required by `ActionDispatch::Session::AbstractStore`
      def write_session(req, sid, session, options)
        @middleware.write_session(req, sid, session, options)
      end

      # Required by `ActionDispatch::Session::AbstractStore`
      def delete_session(req, sid, options)
        @middleware.delete_session(req, sid, options)
      end

      # rubocop:disable Metrics
      def config_file
        file = ENV.fetch('AWS_DYNAMO_DB_SESSION_CONFIG_FILE', nil)
        file ||= Rails.root.join("config/dynamo_db_session_store/#{Rails.env}.yml")
        file = Rails.root.join('config/dynamo_db_session_store.yml') unless File.exist?(file)
        if File.exist?(file)
          Rails.logger.warn('The dynamo_db_session_store configuration file has been renamed.' \
                            'Please use aws_dynamo_db_session_store/<Rails.env>.yml or ' \
                            'aws_dynamo_db_session_store.yml. This will be removed in ' \
                            'aws-actiondispatch-dynamodb ~> 1')
        else
          file = Rails.root.join("config/aws_dynamo_db_session_store/#{Rails.env}.yml")
          file = Rails.root.join('config/aws_dynamo_db_session_store.yml') unless File.exist?(file)
        end

        file if File.exist?(file)
      end
    end
    # rubocop:enable Metrics

    # @api private
    class DynamodbStore < DynamoDbStore
      def initialize(app, options = {})
        Rails.logger.warn('** Session Store :dynamodb_store configuration key has been renamed to :dynamo_db_store, ' \
                          'please use the new key instead. The :dynamodb_store key name will be removed in ' \
                          'aws-actiondispatch-dynamodb ~> 1 **')
        super
      end
    end
  end
end
