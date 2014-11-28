class ImageTranslator

  include ImageToText;
  include CacheKnowledge;

  def initialize(l, u)
    @language = l
    @img_url = u
  end

  # This method defines basic functionality and calls all the other behaviours to translate image.
  def main()
    require 'unirest'
    require 'base64'

    # Creates object of class that is responsible for translation of description to other language.
    translator = Translation.new

    solution = {}


    response = Unirest.get 'http://' + @img_url


    # Use cache if it is possible.
    img_hash = Digest::SHA1.hexdigest response.body



    cached_img = Image.find_by_id(img_hash)
    # use_cache = true         ### We are initially interested in using cache
    if (cached_img != nil) #&&(use_cache==true)

      audio = Voice.find_by_id(cached_img.description+","+cached_img.verb+","+cached_img.adj+","+@language)

      if (audio != nil)
        solution['audio_response'] = Base64.decode64(audio.voice_blob);
      else
        puts cached_img.adj
        sentence = cached_img.adj + " " + cached_img.verb + " " + cached_img.description
        sentence = translator.translate sentence, @language

        url = 'http://translate.google.com/translate_tts?tl='+@language+'&q='+sentence
        solution['audio_response'] = (Unirest.get URI.parse(URI.encode(url)).to_s).body
        cache_audio_async(cached_img.description+","+cached_img.verb+","+cached_img.adj+","+@language, solution["audio_response"])
      end

    else

      #for testing purposes I pass the whole blob. In the final version we will pass the url of the image for the google.
      solution = convertImageToText(response.body)
      feedbackID = SecureRandom.base64(20)


      #get our learned solution
      our_suggestion = getOppinion(solution["similar_ids"])
      if (our_suggestion[1] > 20)
        solution["description"] = our_suggestion[0]
      end

      sentence = solution["adj"] +' '+ solution["verb"]+ ' ' + solution["description"]


      sentence = translator.translate sentence, @language


      url = 'http://translate.google.com/translate_tts?tl='+@language+'&q='+sentence


      audio_response = Unirest.get URI.parse(URI.encode(url)).to_s
      solution['audio_response'] = audio_response.body

      cache_image_async({"id" => img_hash, "description" => solution["description"], "verb" => solution["verb"], "adj" => solution["adj"]}, solution["similar_ids"], feedbackID)

      cache_audio_async(solution["description"]+","+solution["verb"]+","+solution["adj"]+","+@language, solution["audio_response"])

      #render :text =>convert_response["description"]


    end


    #render :text =>solution['audio_response']

    return solution['audio_response']
  end

end



