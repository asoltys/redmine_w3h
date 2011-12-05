class ViewUsersForm < Redmine::Hook::ViewListener

  def view_users_form(context = { })
    "<p>#{context[:form].text_field :quota, :required => false}</p>"
  end
end
