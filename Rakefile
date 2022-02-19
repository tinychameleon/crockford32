# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
require "rdoc/task"
require "standard/rake"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/test_*.rb"]
end

RDoc::Task.new do |r|
  r.main = "README.md"
  r.rdoc_files.include "README.md", "CHANGELOG.md", "lib/**/*.rb"
end

task default: %i[test standard]

desc "Benchmark the current implementation"
task benchmark: [] do |t|
  sh "date; ruby test/benchmarks/current.rb"
end
