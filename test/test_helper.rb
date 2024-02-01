# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'minitest/autorun'
require 'minitest/reporters'
require 'mocha/minitest'
require 'time'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new # spec-like progress
