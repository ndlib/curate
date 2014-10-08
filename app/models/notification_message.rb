class NotificationMessage
  attr_accessor :message_id, :target_pid

  def initialize(message_id, target_pid)
    self.message_id = message_id
    self.target_pid = target_pid
  end

  def to_s
    "#{self.message_id} => #{self.target_pid}"
  end
end
