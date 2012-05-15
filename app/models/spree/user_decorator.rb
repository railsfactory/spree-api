Spree::User.class_eval do
  def generate_api_key!
    self.api_key = SecureRandom.hex(24)
    self.reset_authentication_token!
    save!
  end

  def clear_api_key!
    self.api_key = nil
    self.update_attribute(:authentication_token, "")
    save!
  end

  private

  def secure_digest(*args)
    Digest::SHA1.hexdigest(args.flatten.join('--'))
  end
end
