require 'redmine'

Redmine::Plugin.register :redmine_new_issues do
  name 'Redmine New Issues plugin'
  author 'Roman Shipiev'
  description 'Block for my/page and rake-task for mail delivery (IssueStatus.default)'
  version '0.0.1'
  url 'https://github.com/rubynovich/redmine_new_issues'
  author_url 'http://roman.shipiev.me'
end

if Rails::VERSION::MAJOR < 3
  require 'dispatcher'
  object_to_prepare = Dispatcher
else
  object_to_prepare = Rails.configuration
end

object_to_prepare.to_prepare do
  [:mailer].each do |cl|
    require "new_issues_#{cl}_patch"
  end

  [
    [Mailer, NewIssuesPlugin::MailerPatch]
  ].each do |cl, patch|
    cl.send(:include, patch) unless cl.included_modules.include? patch
  end
end
