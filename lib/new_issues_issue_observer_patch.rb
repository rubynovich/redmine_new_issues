require_dependency 'issue_observer'

module NewIssuesPlugin
  module IssueObserverPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do
        alias_method_chain :after_create, :new_issues
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def after_create_with_new_issues(issue)
        after_create_without_new_issues(issue) if issue.start_date > Date.today
      end
    end
  end
end
