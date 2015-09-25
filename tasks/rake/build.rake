require File.expand_path('../../env', __FILE__)

desc "Clean, run syntax & style checks and spec tests"
task :build do
  Rake::Task[:clean].invoke
  Rake::Task[:syntax].invoke
  Rake::Task[:style].invoke
  Rake::Task[:spec].invoke
end
