class Translation
  require 'bing_translator'

  BING_CLIENT_ID = "Image2Speech"
  BING_CLIENT_SECRET = "agAxWGVs4TYyMWMUtzYGp6pmOPauk6Rk0V07MNICHbQ="

  def initialize()
    begin
      @translator = BingTranslator.new(BING_CLIENT_ID, BING_CLIENT_SECRET)
      token = translator.get_access_token
      token[:status] = 'success'
    rescue Exception => exception
      puts exception.message
      puts exception.backtrace.inspect
      token = { :status => exception.message }
    end
  end

  def translate(text, language)
    result = @translator.translate text, :from => 'en', :to => language
    puts result
  end
end