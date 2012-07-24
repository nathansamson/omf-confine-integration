task :default => 'omf_dev:install'

OMF_VERSION = '5.4'
ROOT = File.expand_path(File.dirname(__FILE__))

namespace :omf_dev do
  desc 'Install OMF Confine components in local development environment.'
  task :install do
    # Experiment Controller
    #
    symlink = "/usr/share/omf-expctl-#{OMF_VERSION}/confine"
    File.symlink("#{ROOT}/omf-expctl/ruby/omf-expctl/confine", symlink) and puts symlink unless File.symlink?(symlink)
    
    symlink = "/usr/share/omf-expctl-#{OMF_VERSION}/confine.rb"
    File.symlink("#{ROOT}/omf-expctl/ruby/omf-expctl/confine.rb", symlink) and puts symlink unless File.symlink?(symlink)
    
    symlink = "/usr/share/omf-expctl-#{OMF_VERSION}/repository/confine"
    File.symlink("#{ROOT}/omf-expctl/ruby/repository/confine", symlink) and puts symlink unless File.symlink?(symlink)
    
    
    # Aggregate Manager Services
    symlink = "/usr/share/omf-aggmgr-#{OMF_VERSION}/omf-aggmgr/ogs_confine"
    File.symlink("#{ROOT}/omf-aggmgr/ruby/ogs_confine", symlink) and puts symlink unless File.symlink?(symlink)
  end

  desc 'Remove OMF Confine components from local development environment.'
  task :remove do
    [
      "/usr/share/omf-aggmgr-#{OMF_VERSION}/omf-aggmgr/ogs_confine",
      "/usr/share/omf-expctl-#{OMF_VERSION}/confine.rb",
      "/usr/share/omf-expctl-#{OMF_VERSION}/confine",
      "/usr/share/omf-expctl-#{OMF_VERSION}/repository/confine",
    ].each do |s|
      File.unlink(s) && puts("Removed #{s}") if File.symlink?(s)
    end
  end
end
