# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "android_debug"
  gem.homepage = "http://github.com/wuntee/android_debug"
  gem.license = "MIT"
  gem.summary = "A scriptable debugger to interact with Android applications"
  gem.description = ""
  gem.email = "mathew.rowley@gmail.com"
  gem.authors = ["wuntee"]
  gem.platform = "java"
  gem.files = Dir.glob('lib/**/*.rb')
  # dependencies defined in Gemfile
end

# Not yet...
#Jeweler::RubygemsDotOrgTasks.new

=begin
require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
  test.rcov_opts << '--exclude "gems/*"'
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "android_debug #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
=end
require 'yard'

#module YARD::Templates::Helpers::HtmlHelper
#  def html_markup_markdown(text)
#    markup_class(:markdown).new(text, :gh_blockcode, :fenced_code, :autolink, :tables).to_html
#  end
#end

YARD::Rake::YardocTask.new('doc') do |doc|
  doc.options << '-m' << 'markdown' << '-M' << 'kramdown'
  doc.options << '--protected' << '--no-private'
  doc.options << '-r' << 'README.rdoc'
  doc.options << '-o' << 'doc'
  doc.options << '--title' << "Android Scriptable Debugger Framework"

  doc.files = %w( lib/**/*.rb README.rdoc )
end
