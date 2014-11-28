module ImageToText

  def convertImageToText(img_blob)


    #writting to the blob to a file to be able to send it. Still need to be fixed so we dont need to save it to
    #a file but send the blob directly.
    open('image.jpg', 'wb') do |file|
      file << img_blob
    end


    #I modified the following to lines to be able to set the user-agent and accept-encouding header in the
    #http request. the modification made in the followong file unirest.rb. Can be found where the os
    #stores the gem files

=begin Replace these 2 lines of code in the gem 'unirest' by next two
  http_request.add_header("user-agent", Unirest.user_agent)
  http_request.add_header("accept-encoding", "gzip")

  http_request.add_header("user-agent", "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36")
  http_request.add_header("accept-encoding", "gzip, deflate")
=end

    require 'unirest'
    require 'engtagger'
    require "net/http"
    require "uri"
    require 'json'


    #sending the image to google.
    response = Unirest.post "http://www.google.co.uk/searchbyimage/upload",
                            headers: {"Accept" => "application/json"},
                            parameters: {:encoded_image => File.new("image.jpg", 'rb')}


    #the response containes a link where the searching result can be found. I grab it from the answer.
    index1 = response.body.index('HREF="')+11
    index2 = response.body.index('">here')
    link = response.body[index1, index2-index1]


    #send the html query to the link we got from the previous answer
    response = Unirest.get 'http:' + link


    #If the google finds a very accurate match it gives a hint which word should be used in the searchbar to
    #find similar images. If it exists I return with that fraze so we can us it.
    guess_index = response.body.index('Best guess for this image:')

    if guess_index != nil
      guess_pos1 = response.body.index(">", guess_index)+1
      guess_pos2 = response.body.index('</', guess_pos1)

      return {"description" =>response.body[guess_pos1,guess_pos2-guess_pos1], "verb" => "", "adj" => "", 'similar_ids' => []}

    end


    #if there is no such clear match google offers some pages where similar image can be found.
    #we dont need it. We want to go the the similar images page where every similar image can
    #be found with the title and the description. I dig the link to this page out here.
    similar_index = response.body.index('<div class="_Icb _kk _wI">')
    similar_url ='';
    if similar_index != nil
      similar_pos1 = response.body.index('href="', similar_index)+6
      similar_pos2 = response.body.index('">', similar_pos1)
      similar_url = response.body[similar_pos1, similar_pos2-similar_pos1]
    end

    #for some reason the response contains the html code for &. I need to change it back in order to have the link work
    similar_url = similar_url.gsub('&amp;', '&') # we need this cause for an unknown reason in the string & is replaced by the html couterpert &amp; which results an invalid query


    #send the last http query to google to get the page with the similat images and names and descriptions.
    response = Unirest.get 'http://www.google.com' + similar_url


    #start building a json object from the descriptions in the html response
    descriptions = '{"images":['

    #after this we can find all information of one similar image.
    next_description_index = response.body.index('<div class="rg_meta">')

    #iterate the pictures in the html file
    while next_description_index != nil
      next_description_index += 21
      description_end_index = response.body.index('</div>', next_description_index)
      descriptions += response.body[next_description_index, description_end_index-next_description_index] + ','

      #if nil then no more pic
      next_description_index = response.body.index('<div class="rg_meta">', next_description_index+1)
    end

    descriptions = descriptions[0...-1] #remove the last comma
    descriptions += ']}'

    data = JSON.parse(descriptions)
    words = ""


    #this was the very moment when I totally fell in love with ruby. It would be even longer to describe in
    #english what it does. gets every description and image names and removes the unnecessary chars like '@'
    #Then searches for an uppercase-lowercase pattern cause some times ImageNamesWrittenInThisWay and need
    #to separate these words with a space. then divide everything to words and attache to the word array.
    #And the winner is ruby cause the description is longer :)

    #render :text =>data['images']
    similar_img_ids = Array.new
    data['images'].each do |img|
      similar_img_ids.push(img['id'])
      [img['fn'], img['pt']].each { |str|

        ['jpg', 'free', 'are', 'png', 'gif'].each { |replacement| str.gsub!(replacement, ' ') }
        str.gsub!(/[^A-Za-z]/, '')
        str.gsub!(/[[:upper:]][[:lower:]]/, ' \0') # So awesome I almost cried
        str.gsub!('ing ', ' ')
        str.split(' ').each { |word|
          if ((word.downcase != nil)&&(word != '')&&(word != ' ')&&(word.length > 2))
            words += word.downcase + " ";
          end
        }
      }
    end

      # creating an object of tagger
      tgr = EngTagger.new
      # Adding tags to every word
      tagged = tgr.add_tags(words)

      adjs = tgr.get_adjectives(tagged)
      nouns = tgr.get_nouns(tagged)



    # Add Colours from nouns from adjectives
       nouns.each{|noun, frequency|
        if ["white", "black", "red", "yellow", "green", "blue", "green", "pink", "grey", "purple", "orange"].include? noun
          adjs[noun] = frequency
          nouns[noun] = 0
        end
      }

      most_frequent_noun = nouns.max_by { |k, v| v }

      puts most_frequent_noun

     # most_frequent_noun.each do |key, value|
      #  puts key + ' : ' + value
      #end

      verbs = tgr.get_base_present_verbs(tagged)
      verbs = verbs.merge(tgr.get_infinitive_verbs(tagged))
      most_frequent_verb = verbs.max_by { |k, v| v }
    puts most_frequent_verb


    # !!!!!!!!!We actually dont know whz our program likes word free. And even code on line 115 DOES NOT REMOVE THAT! MAGIC?
    adjs['free'] = 0;

      most_frequent_adj = adjs.max_by { |k, v| v }
    puts most_frequent_adj



    else if most_frequent_verb == nil || most_frequent_verb[1] < 6
       most_frequent_verb = Array.new
       most_frequent_verb.push('')
       most_frequent_verb.push(0)
    end

     if  most_frequent_adj == nil || most_frequent_adj[1] < 4
           most_frequent_adj = Array.new
           most_frequent_adj.push('')
           most_frequent_adj.push(0)
         end




    return {"description" => most_frequent_noun[0], "verb" => most_frequent_verb[0], "adj" => most_frequent_adj[0], 'similar_ids' => similar_img_ids}


    end
#/home/ed/Documents/railsworkspace/i2s/app/helpers/image_to_text.rb:185: warning: else without rescue is useless




end