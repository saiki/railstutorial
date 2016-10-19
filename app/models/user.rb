class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save   :downcase_email
  before_create :create_activation_digest
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # �^����ꂽ������̃n�b�V���l��Ԃ� 
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # �����_���ȃg�[�N����Ԃ�
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # �i���I�Z�b�V�����Ŏg�p���郆�[�U�[���f�[�^�x�[�X�ɋL������
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # �n���ꂽ�g�[�N�����_�C�W�F�X�g�ƈ�v������true��Ԃ�
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # �g�[�N�����_�C�W�F�X�g�ƈ�v������true��Ԃ�
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # ���[�U�[���O�C����j������
  def forget
    update_attribute(:remember_digest, nil)
  end

  # �A�J�E���g��L���ɂ���
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # �L�����p�̃��[���𑗐M����
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # �p�X���[�h�Đݒ�̑�����ݒ肷��
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # �p�X���[�h�Đݒ�̃��[���𑗐M����
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # �p�X���[�h�Đݒ�̊������؂�Ă���ꍇ��true��Ԃ�
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # ����feed�̒�`
  # ���S�Ȏ����͑�12�́u���[�U�[���t�H���[����v���Q�Ƃ��Ă��������B
  def feed
    Micropost.where("user_id = ?", id)
  end

  private

    # ���[���A�h���X�����ׂď������ɂ���
    def downcase_email
      self.email = email.downcase
    end

    # �L�����g�[�N���ƃ_�C�W�F�X�g���쐬����ё������
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
