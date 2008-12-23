require 'rubygems'

# A wrapper for notifiers in various plataforms.
#
# It can handle libnotify in Unix-plataforms, snarl on Windows, and Growl in
# in Mac OS X. The proper ruby bindings for those libraries must be installed.
class NotifierWrapper
  # Initializes the notifier if necessary.
  #
  # The options hash is used to send options to the notifier.
  def initialize(options = {})
    if require_available_notifier
      @available = true
      initialize_notifier(options)
    end
  end

  # Returns true if there is a notifier was initialized and is available for use.
  def available?
    @available
  end

  # Returns the name of the notifier which is being used.
  def notifier_name
    @notifier_name
  end

  # Sends a notification to the notifier being used.
  #
  # A title must be given, as well as a message. Other options are optional and
  # depend upon the notifier being used.
  #
  # For libnotify these options apply:
  # - *icon*: The full path to a icon to be displayed (Gdk::Pixbuf will be used)
  # - *widget*: A widget to attach the notification to
  # - *timeout*: A timeout, in seconds, for the notification (nil if you want a sticky one)
  # - *urgency*: The urgency level
  # - *category*: The category of the notification
  #
  # For Snarl these options apply:
  # - *icon*: The full path to a icon to be displayed
  # - *timeout*: A timeout, in seconds, for the notification (nil if you want a sticky one)
  #
  # For Growl these options apply:
  # - *timeout*: A timeout, in seconds, for the notification (nil if you want a sticky one)
  # - *urgency*: The urgency level
  # - *category*: The category of the notification
  def notify(title, message = nil, options = {})
    options.each { |key, value| options[key] = convert(value) }
    send("notify_with_#{@notifier_name}", convert(title), convert(message), options)
  end

  private
    def require_available_notifier
      require_libnotify || require_snarl || require_growl
    end

    def require_libnotify
      require 'rnotify'
      @notifier_name = :libnotify
      true
    rescue LoadError
      false
    end

    def require_snarl
      require 'snarl'
      @notifier_name = :snarl
    rescue LoadError, RuntimeError
      false
    end

    def require_growl
      require 'ruby-growl'
      @notifier_name = :growl
    rescue LoadError
      false
    end

    def initialize_notifier(options)
      send("initialize_#{@notifier_name}", options)
    end

    def initialize_libnotify(options)
      @notifier = Notify.init(options[:application_name])
    end

    def initialize_snarl(options)

    end

    def initialize_growl(options)
      @notifier = Growl.new(
        options[:host] || 'localhost',
        options[:application_name],
        options[:all_notifies] || ['default_notification'],
        options[:default_notifies],
        options[:password]
      )
    end

    def notify_with_libnotify(title, message, options)
      @notification = Notify::Notification.new(title, message, options[:icon], options[:widget])
      @notification.timeout = options[:timeout] * 1000 if options.has_key?(:timeout)
      @notification.urgency = options[:urgency] if options.has_key?(:urgency)
      @notification.category = options[:category] if options.has_key?(:category)
      @notification.show
    end

    def notify_with_snarl(title, message, options)
      Snarl.show_message(title, message, options[:icon], options[:timeout] || Snarl::NO_TIMEOUT)
    end

    def notify_with_growl(title, message, options)
      @notifier.notify(options[:category].to_s, title, message, options[:urgency], options[:timeout].nil?)
    end
    
    # This method is needed since values passed to notifiers come from
    # observable properties, and some notifiers have trouble casting them to
    # proper values. :(
    def convert(value)
      unless value.nil?
        if value.is_a?(String)
          value = value.to_s
        elsif value.is_a?(Fixnum)
          value = value.to_i
        elsif value.is_a?(Float)
          value = value.to_f
        end
      end
      value
    end
end