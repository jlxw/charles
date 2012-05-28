#!/usr/bin/env rake
require "bundler/gem_tasks"

#http://guides.rubygems.org/make-your-own-gem/
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

desc "Run tests"
task :default => :test

