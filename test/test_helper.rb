# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/unit' if RUBY_VERSION < '3.2'
require 'minitest/mock' if RUBY_VERSION >= '3.2'
require 'minitest-spec-rails'

ENV['RAILS_ENV'] = 'test'

require_relative 'dummy/config/application'

Rails.application.initialize!
