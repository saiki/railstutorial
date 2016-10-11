module SessionsHelper

  # �n���ꂽ���[�U�[�Ń��O�C������
  def log_in(user)
    session[:user_id] = user.id
  end

  # ���݃��O�C�����Ă��郆�[�U�[��Ԃ� (���[�U�[�����O�C�����̏ꍇ�̂�)
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  # ���[�U�[�����O�C�����Ă����true�A���̑��Ȃ�false��Ԃ�
  def logged_in?
    !current_user.nil?
  end
end
