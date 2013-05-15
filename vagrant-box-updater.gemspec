# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-box-updater/version'

Gem::Specification.new do |gem|
  gem.name          = "vagrant-box-updater"
  gem.version       = Vagrant::BoxUpdater::VERSION
  gem.authors       = ["Ruslan Lutsenko"]
  gem.email         = ["ruslan.lutcenko@gmail.com"]
  gem.description   = "vagrant plugin which save details about added box image (image creation timestamp image source path), during start of virtual machine checks the source url of a box image for updates (use 'Last-Modified' header to detect changes), notify user and perform interactive download of the box image if update detected"
  gem.summary       = "vagrant plugin to monitor and notify about updates of remote box images"
  gem.homepage      = ""

  #gem.files         = `git ls-files`.split($/)
  #gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  #gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  #gem.require_paths = ["lib"]
	# The following block of code determines the files that should be included
  # in the gem. It does this by reading all the files in the directory where
  # this gemspec is, and parsing out the ignored files from the gitignore.
  # Note that the entire gitignore(5) syntax is not supported, specifically
  # the "!" syntax, but it should mostly work correctly.
  root_path      = File.dirname(__FILE__)
  all_files      = Dir.chdir(root_path) { Dir.glob("**/{*,.*}") }
  all_files.reject! { |file| [".", ".."].include?(File.basename(file)) }
  gitignore_path = File.join(root_path, ".gitignore")
  gitignore      = File.readlines(gitignore_path)
  gitignore.map!    { |line| line.chomp.strip }
  gitignore.reject! { |line| line.empty? || line =~ /^(#|!)/ }

  unignored_files = all_files.reject do |file|
    # Ignore any directories, the gemspec only cares about files
    next true if File.directory?(file)

    # Ignore any paths that match anything in the gitignore. We do
    # two tests here:
    #
    #   - First, test to see if the entire path matches the gitignore.
    #   - Second, match if the basename does, this makes it so that things
    #     like '.DS_Store' will match sub-directories too (same behavior
    #     as git).
    #
    gitignore.any? do |ignore|
      File.fnmatch(ignore, file, File::FNM_PATHNAME) ||
        File.fnmatch(ignore, File.basename(file), File::FNM_PATHNAME)
    end
  end

  gem.files         = unignored_files
  gem.executables   = unignored_files.map { |f| f[/^bin\/(.*)/, 1] }.compact
  gem.require_path  = 'lib'
end
