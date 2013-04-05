require 'rspec/core/rake_task'

require File.expand_path('../../env', __FILE__)

desc "Run puppet module RSpec tests"
RSpec::Core::RakeTask.new(:spec_standalone) do |t|
  t.rspec_opts = ["--format", "doc", "--color"]
  t.fail_on_error = false
  t.pattern = 'spec/{classes,defines,unit,functions,hosts}/**/*_spec.rb'
end

# This is a helper for the self-symlink entry of fixtures.yml
def source_dir
  Dir.pwd
end

def fixtures(category)
  begin
    fixtures = YAML.load_file(".fixtures.yml")["fixtures"]
  rescue Errno::ENOENT
    return {}
  end

  if not fixtures
    abort("malformed fixtures.yml")
  end

  result = {}
  if fixtures.include? category
    fixtures[category].each do |fixture, opts|
      if opts.instance_of?(String)
        source = opts
        target = "spec/fixtures/modules/#{fixture}"
        real_source = eval('"'+source+'"')
        result[real_source] = target
      elsif opts.instance_of?(Hash)
        target = "spec/fixtures/modules/#{fixture}"
        real_source = eval('"'+opts["repo"]+'"')
        result[real_source] = { "target" => target, "ref" => opts["ref"] }
      end
    end
  end
  return result
end

desc "Create the fixtures directory"
task :spec_prep do
  fixtures("repositories").each do |remote, opts|
    if opts.instance_of?(String)
      target = opts
      ref = "refs/remotes/origin/master"
    elsif opts.instance_of?(Hash)
      target = opts["target"]
      ref = opts["ref"]
    end

    unless File::exists?(target) || system("git clone #{remote} #{target}")
      fail "Failed to clone #{remote} into #{target}"
    end
    system("cd #{target}; git reset --hard #{ref}") if ref
  end

  FileUtils::mkdir_p("spec/fixtures/modules")
  fixtures("symlinks").each do |source, target|
    File::exists?(target) || FileUtils::ln_s(source, target)
  end

  FileUtils::mkdir_p("spec/fixtures/manifests")
  FileUtils::touch("spec/fixtures/manifests/site.pp")
end

desc "Clean up the fixtures directory"
task :spec_clean do
  fixtures("repositories").each do |remote, opts|
    if opts.instance_of?(String)
      target = opts
    elsif opts.instance_of?(Hash)
      target = opts["target"]
    end
    FileUtils::rm_rf(target)
  end

  fixtures("symlinks").each do |source, target|
    FileUtils::rm(target)
  end
  site = "spec/fixtures/manifests/site.pp"
  if File::exists?(site) and ! File.size?(site)
    FileUtils::rm("spec/fixtures/manifests/site.pp")
  end
end

desc "Run spec tests in a clean fixtures directory"
task :spec do
  Rake::Task[:spec_prep].invoke
  Rake::Task[:spec_standalone].invoke
  Rake::Task[:spec_clean].invoke
end
