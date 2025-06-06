# frozen_string_literal: true

namespace 'dynamo_db' do
  namespace 'session_store' do
    desc 'Create the Amazon DynamoDB session store table'
    task create_table: :environment do
      options = Rails.application.config.session_options
      Aws::SessionStore::DynamoDB::Table.create_table(options)
    end

    desc 'Delete the Amazon DynamoDB session store table'
    task delete_table: :environment do
      options = Rails.application.config.session_options
      Aws::SessionStore::DynamoDB::Table.delete_table(options)
    end

    desc 'Clean up old sessions in the Amazon DynamoDB session store table'
    task clean: :environment do
      options = Rails.application.config.session_options
      Aws::SessionStore::DynamoDB::GarbageCollection.collect_garbage(options)
    end
  end
end
