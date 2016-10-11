module SessionsHelper

  # �n���ꂽ���[�U�[�Ń��O�C������
  def log_in(user)
    session[:user_id] = user.id
  end

  # ���[�U�[���i���I�Z�b�V�����ɋL������
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # ���݃��O�C�����Ă��郆�[�U�[��Ԃ� (���[�U�[�����O�C�����̏ꍇ�̂�)
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # ���[�U�[�����O�C�����Ă����true�A���̑��Ȃ�false��Ԃ�
  def logged_in?
    !current_user.nil?
  end

  # �i���I�Z�b�V������j������
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # ���݂̃��[�U�[�����O�A�E�g����
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
end
