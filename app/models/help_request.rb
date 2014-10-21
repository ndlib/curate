require 'browser'
class HelpRequest < ActiveRecord::Base

  belongs_to :user
  validates_presence_of :name,
    :message => "Please enter your name"
  validates_presence_of :email,
    :message => "Please provide an email address."
  validates_presence_of :how_can_we_help_you,
    :message => "Please tell us about the problem or issue you are having with #{I18n.t('sufia.product_name')}."

  after_save :send_notification

  def browser_name
    parse_user_agent
    @browser.name
  end

  def form_email
    if user
      user.email || ''
    else
      ''
    end
  end

  def form_name
    if user
      user.user_key || ''
    else
      ''
    end
  end

  def platform
    parse_user_agent
    @browser.platform
  end

  def sender_email
    user.try(:email) || email || I18n.t('sufia.help_email')
  end

  def user_name
    user.try(:user_key) || name || 'Unknown'
  end

  private

  def parse_user_agent
    @browser ||= Browser.new(:ua => user_agent)
  end

  def send_notification
    Sufia.queue.push(NotificationWorker.new(id))
  end
end
