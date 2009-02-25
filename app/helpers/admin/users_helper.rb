module Admin::UsersHelper
  def admin_user_operation(selected = request.request_uri)
    options_for_select([
      [ _("menu"), nil],
      [_("manage users"), admin_root_path],
      [_("Account|Index"), admin_accounts_path],
    ], selected)
  end
end
