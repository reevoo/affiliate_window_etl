begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)
  task default: :spec
rescue LoadError
  puts "RSpec not loaded"
end

begin
  require "bundler/audit/task"
  Bundler::Audit::Task.new
  task default: "bundle:audit"
rescue LoadError
  puts "bundler-audit not loaded"
end

$LOAD_PATH.unshift("lib")
load "affiliate_window/etl/tasks.rake"
