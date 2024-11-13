# ActionDispatch Session Storage with Amazon DynamoDB

[![Gem Version](https://badge.fury.io/rb/aws-actiondispatch-dynamodb-ruby.svg)](https://badge.fury.io/rb/aws-actiondispatch-dynamodb-ruby)
[![Build Status](https://github.com/aws/aws-actiondispatch-dynamodb-ruby/workflows/CI/badge.svg)](https://github.com/aws/aws-actiondispatch-dynamodb-ruby/actions)
[![Github forks](https://img.shields.io/github/forks/aws/aws-actiondispatch-dynamodb-ruby.svg)](https://github.com/aws/aws-actiondispatch-dynamodb-ruby/network)
[![Github stars](https://img.shields.io/github/stars/aws/aws-actiondispatch-dynamodb-ruby.svg)](https://github.com/aws/aws-actiondispatch-dynamodb-ruby/stargazers)

This gem contains an
[ActionDispatch AbstractStore](https://api.rubyonrails.org/classes/ActionDispatch/Session/AbstractStore.html)
implementation that uses Amazon DynamoDB as a session store, allowing access
to sessions from other applications and devices.

## Installation

Add this gem to your Rails project's Gemfile:

```ruby
gem 'aws-sdk-rails', '~> 4'
gem 'aws-actiondispatch-dynamodb', '~> 0'
```

Then run `bundle install`.

This gem also brings in the following AWS gems:

* `aws-sessionstore-dynamodb` -> `aws-sdk-dynamodb`

You will have to ensure that you provide credentials for the SDK to use. See the
latest [AWS SDK for Ruby Docs](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/index.html#Configuration)
for details.

If you're running your Rails application on Amazon EC2, the AWS SDK will
check Amazon EC2 instance metadata for credentials to load. Learn more:
[IAM Roles for Amazon EC2](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html)

## Usage

To use the session store, add or edit your
`config/initializers/session_store.rb` file:

```ruby
options = { table_name: '_your_app_session' }
Rails.application.config.session_store :dynamo_db_store, **options
```

You can now start your Rails application with DynamoDB session support.

**Note**: You will need a DynamoDB table to store your sessions. You can create
the table using the provided Rake tasks or ActiveRecord migration generator
after configuring.

## Configuration

You can configure the session store with code, ENV, or a YAML file, in this
order of precedence. To configure in code, you can directly pass options to your
`config/initializers/session_store.rb` file like so:

```ruby
options = {
  table_name: 'your-table-name',
  table_key: 'your-session-key',
  dynamo_db_client: Aws::DynamoDB::Client.new(region: 'us-west-2')
} 
Rails.application.config.session_store :dynamo_db_store, **options
```

The session store inherits from the
[`Rack::Session::Abstract::Persisted`](https://rubydoc.info/github/rack/rack-session/main/Rack/Session/Abstract/Persisted)
class, which also supports additional options (such as `:key`).

For more information about this feature and configuration options, see the
[Configuration](https://docs.aws.amazon.com/sdk-for-ruby/aws-sessionstore-dynamodb/api/Aws/SessionStore/DynamoDB/Configuration.html)
class and the
[GitHub repository](https://github.com/aws/aws-sessionstore-dynamodb-ruby).

### Configuration file generator

You can generate a configuration file for the session store using the following
command (--environment=<environment> is optional):

```bash
rails generate dynamo_db:session_store_config --environment=<Rails.env>
```

The session store configuration generator command will generate a YAML file
`config/aws_dynamo_db_session_store.yml` with default options. If provided an
environment, the file will be named
`config/aws_dynamo_db_session_store/<Rails.env>.yml`, which takes precedence
over the default file.

## Migration

### ActiveRecord Migration generator

You can generate a migration file for the session table using the following
command (<MigrationName> is optional):

```bash
rails generate dynamo_db:session_store_migration <MigrationName>
```

The session store migration generator command will generate a
migration file  `db/migration/#{VERSION}_#{MIGRATION_NAME}.rb`.

The migration file will create and delete a table with default options. These
options can be changed prior to running the migration either by changing the
configuration in the initializer, editing the migration file, in ENV, or in the
config YAML file. These options are documented in the
[Table](https://docs.aws.amazon.com/sdk-for-ruby/aws-sessionstore-dynamodb/api/Aws/SessionStore/DynamoDB/Table.html)
class.

To create the table, run migrations as normal with:

```bash
rails db:migrate
```

To delete the table and rollback, run the following command:

```bash
rails db:migrate:down VERSION=<VERSION>
```

### Migration Rake tasks

If you are not using ActiveRecord, you can manage the table using the provided
Rake tasks:

```bash
rake dynamo_db:session_store:create_table
rake dynamo_db:session_store:delete_table
```

The rake tasks will create and delete a table with default options. These
options can be changed prior to running the task either by changing the
configuration in the initializer, in ENV, or in the config YAML file. These
options are documented in the
[Table](https://docs.aws.amazon.com/sdk-for-ruby/aws-sessionstore-dynamodb/api/Aws/SessionStore/DynamoDB/Table.html)
class.

## Cleaning old sessions

By default sessions do not expire. You can use `:max_age` and `:max_stale` to
configure the max age or stale period of a session.

You can use the DynamoDB
[Time to Live (TTL) feature](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/TTL.html)
on the `expire_at` attribute to automatically delete expired items, saving you
the trouble of manually deleting them and reducing costs.

If you wish to delete old sessions based on creation age (invalidating valid
sessions) or if you want control over the garbage collection process, you can
use the provided Rake task:

```bash
rake dynamo_db:session_store:clean
```

The rake task will clean the table with default options. These options can be
changed prior to running the task either by changing the configuration in the
initializer, in ENV, or in the config YAML file. These options are documented in
the
[GarbageCollector](https://docs.aws.amazon.com/sdk-for-ruby/aws-sessionstore-dynamodb/api/Aws/SessionStore/DynamoDB/GarbageCollector.html)
class.