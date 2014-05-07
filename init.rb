require 'redmine'

Redmine::Plugin.register :redmine_new_issues do
  name 'New Issues'
  author 'Roman Shipiev'
  description 'Block for my/page and rake-task for mail delivery (IssueStatus.default)'
  version '0.0.2'
  url 'https://bitbucket.org/gorkapstroy/redmine_new_issues'
  author_url 'http://roman.shipiev.me'
end

if Rails::VERSION::MAJOR < 3
  require 'dispatcher'
  object_to_prepare = Dispatcher
else
  object_to_prepare = Rails.configuration
end

object_to_prepare.to_prepare do
  [:mailer,  (Redmine::VERSION::MAJOR >= 2 && Redmine::VERSION::MINOR >= 5) ? :issue : :issue_observer].each do |cl|
    require "new_issues_#{cl}_patch"
  end

  [
    [Mailer, NewIssuesPlugin::MailerPatch],
    ((Redmine::VERSION::MAJOR >= 2 && Redmine::VERSION::MINOR >= 5) ? [Issue, NewIssuesPlugin::IssuePatch] : [IssueObserver, NewIssuesPlugin::IssueObserverPatch])
  ].each do |cl, patch|
    cl.send(:include, patch) unless cl.included_modules.include? patch
  end
end
