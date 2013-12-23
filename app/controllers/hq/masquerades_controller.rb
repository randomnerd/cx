class Hq::MasqueradesController < Hq::BaseController
  skip_before_filter :check_admin, only: [:destroy]
  def create
    session[:admin_id] = current_user.id
    session[:admin_path] = request.env['HTTP_REFERER']
    sign_in User.find(params[:id])
    redirect_to root_path
  end

  def destroy
    sign_in :user, User.find(session[:admin_id])
    redirect_to session[:admin_path] || hq_root_path
    session[:admin_id] = nil
    session[:admin_path] = nil
  end
end
