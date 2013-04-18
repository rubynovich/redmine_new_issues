require_dependency 'mailer'

module NewIssuesPlugin
  module MailerPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do
      end
    end

    module ClassMethods
      def new_issues(options={})
        mailcopy = options[:cc]
        status = IssueStatus.default
        new_issues = Issue.open.where(:status_id => status.id).where("start_date <= ?", Date.today)
        new_issues.map(&:assigned_to).uniq.map do |user|
          new_issues_mail(user, new_issues.where(:assigned_to_id => user.id), mailcopy).deliver
        end
      end
    end

    module InstanceMethods
      def new_issues_mail(user, new_issues, mailcopy)
        set_language_if_valid user.language
        issues_count = new_issues.count
        subject = case issues_count
          when 1 then  l(:mail_subject_new_issues1, :count => issues_count)
          when 2..4 then l(:mail_subject_new_issues2, :count => issues_count)
          else l(:mail_subject_new_issues5, :count => issues_count)
        end
        status = IssueStatus.default
        @new_issues = new_issues
        @firstname = user.firstname
        @lastname = user.lastname
        @issues_url = url_for(:controller => 'issues', :action => 'index', :set_filter => 1, :assigned_to_id => 'me', :status_id => status.id, :start_date => "<t-0", :sort => 'priority:desc,updated_on:desc')
        mail(:to => user.mail, :cc => mailcopy, :subject => subject) if user.mail.present? && issues_count.nonzero?
      end
    end
  end
end
