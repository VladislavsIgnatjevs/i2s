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

=begin
  http_request.add_header("user-agent", Unirest.user_agent)
  http_request.add_header("accept-encoding", "gzip")

  http_request.add_header("user-agent", "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36")
  http_request.add_header("accept-encoding", "gzip, deflate")
=end

    require 'unirest'

    require "net/http"
    require "uri"
    require 'json'


    #sending the image to google. Note th
    response = Unirest.post "http://www.google.co.uk/searchbyimage/upload",
                            headers:{ "Accept" => "application/json" },
                            parameters:{ :encoded_image => File.new("image.jpg", 'rb')}


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
      return response.body[guess_pos1,guess_pos2-guess_pos1]
    end


    #if there is no such clear match google offers some pages where similar image can be found.
    #we dont need it. We want to go the the similar images page where every similar image can
    #be found with the title and the description. I dig the link to this page out here.
    similar_index = response.body.index('<div class="_Icb _kk _wI">')
    similar_url ='';
    if similar_index != nil
      similar_pos1 = response.body.index('href="', similar_index)+6
      similar_pos2 = response.body.index('">', similar_pos1)
      similar_url = response.body[similar_pos1,similar_pos2-similar_pos1]
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
      descriptions += response.body[next_description_index,description_end_index-next_description_index] + ','

      #if nil then no more pic
      next_description_index = response.body.index('<div class="rg_meta">', next_description_index+1)
    end

    descriptions = descriptions[0...-1] #remove the last comma
    descriptions += ']}'

    data = JSON.parse(descriptions)
    words = Array.new


    #this was the very moment when I totally fell in love with ruby. It would be even longer to describe in
    #english what it does. gets every description and image names and removes the unnecessary chars like '@'
    #Then searches for an uppercase-lowercase pattern cause some times ImageNamesWrittenInThisWay and need
    #to separate these words with a space. then divide everything to words and attache to the word array.
    #And the winner is ruby cause the description is longer :)
    data['images'].each do |img|
      [img['fn'], img['pt']].each {|str|
        ['-' ,'>' ,'<','(',')','/', '_' , ',' , '.' , '@', '–', '|', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'].each {|replacement| str.gsub!(replacement, ' ')}
        str.gsub!(/[[:upper:]][[:lower:]]/, ' \0') # So awesome I almost cried
        str.split(' ').each {|word|
          if ((word.downcase != nil)&&(word != '')&&(word != ' '))
            words.push(word.downcase);
          end
        }
      }
    end


    #building a frequency map for each word. it stores the word as a key and the frequency as a value
    # word=>frequency
    words_frequency_map = {}
    words.each { |i| words_frequency_map.include?(i) ? words_frequency_map[i] += 1 : words_frequency_map[i] = 1}




    #Sometimes different words should be the same. like 10 room, 5 rooms, 9 bedroom should be 24 room at the end
    #so I add the appropriate frequencies to the appropriate words.
    words_frequency_map.each{|key_1, fequency_1|
      words_frequency_map.each{|key_2, fequency_2|
        words_frequency_map[key_1] += words_frequency_map[key_2]  if ((key_2.include? key_1))
      }
    }



    nounlist=File.open('nounlist').read
    nounlist.gsub!(/\r\n?/, '\n')


    #words need to be validated. The answer can only ba a word included by out list
    words_frequency_map_valid ={}
    nounlist.each_line{|noun|
      noun.gsub!("\n","")
      words_frequency_map.each {|word, fequency_2|
        if ((word.include? noun)||(word == noun))
          words_frequency_map_valid.merge!(word => words_frequency_map[word])
        end
      }
    }


    return words_frequency_map_valid.max_by { |k, v| v }[0]






  end



  end