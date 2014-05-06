module Harvester
  class Harvester

    def self.pretty_errors
      yield
    rescue InvalidCredentials => e
      puts "#{e.message}"
      exit 1
    rescue Thor::AmbiguousTaskError => e
      Bundler.ui.error e.message
      exit 15
    rescue Thor::UndefinedTaskError => e
      Bundler.ui.error e.message
      exit 15
    rescue Thor::Error => e
      Bundler.ui.error e.message
      exit 1
    rescue LoadError => e
      raise e unless e.message =~ /cannot load such file -- openssl|openssl.so|libcrypto.so/
      Bundler.ui.error "\nCould not load OpenSSL."
      Bundler.ui.warn <<-WARN, :wrap => true
      You must recompile Ruby with OpenSSL support or change the sources in your \
      Gemfile from 'https' to 'http'. Instructions for compiling with OpenSSL \
      using RVM are available at http://rvm.io/packages/openssl.
      WARN
      Bundler.ui.trace e
      exit 1
    rescue Interrupt => e
      puts "\nQuitting..."
    rescue SystemExit => e
      puts "\nQuitting..."
    rescue Exception => e
      puts "Something went terribly wrong! sorry :("
      puts "\n#{e.message}"
      puts "\n#{e.backtrace.inspect}\n"
    end

  end # Harvester
end # Harvester
