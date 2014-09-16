class HourlyApiKeyLimit < RackApiKeyLimit

  def get_key(request)
    api_key = request.params[param_name]
    "#{param_name}-rate-limit:#{api_key}-#{Time.now.hour}"
  end

  def limit_seconds
    3600
  end

  def retry_after
    (limit_seconds - Time.now.seconds_since_midnight % limit_seconds)
  end

end