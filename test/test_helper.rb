ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  fixtures :all
  include ApplicationHelper

  # �e�X�g���[�U�[�����O�C�����̏ꍇ��true��Ԃ�
  def is_logged_in?
    !session[:user_id].nil?
  end

  # �e�X�g���[�U�[�Ƃ��ă��O�C������
  def log_in_as(user, options = {})
    password    = options[:password]    || 'password'
    remember_me = options[:remember_me] || '1'
    if integration_test?
      post login_path, session: { email:       user.email,
                                  password:    password,
                                  remember_me: remember_me }
    else
      session[:user_id] = user.id
    end
  end

  private

    # �����e�X�g���ł�true��Ԃ�
    def integration_test?
      defined?(post_via_redirect)
    end
end
