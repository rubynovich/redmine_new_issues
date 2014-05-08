module NewIssuesPlugin
  module IssuePatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do
        alias_method_chain :send_notification, :new_issues
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def send_notification_with_new_issues
        send_notification_without_new_issues if self.start_date && (self.start_date <= Date.today)
      end
    end
  end
end
