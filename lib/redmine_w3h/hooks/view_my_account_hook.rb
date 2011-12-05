module RedmineW3H
  module Hooks
    class ViewMyAccountHook < Redmine::Hook::ViewListener
      def view_my_account(context = {})
        "<p>#{context[:form].text_field :quota, :required => false}</p>"
      end
    end
  end
end
