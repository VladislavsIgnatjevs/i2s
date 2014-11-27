module CacheKnowledge
  def cache_image_async(img_cache, similar_ids, feedbackID)
    require 'thread'
    require 'digest/sha1'


    #Thread.new {
      cache_image(img_cache,similar_ids, feedbackID)
    #}
  end

  def cache_audio_async(id, blob)
    require 'thread'
    require 'digest/sha1'
    #Thread.new {
      cache_audio(id,blob)
    #}
  end


  def cache_audio (id,blob)
    require "base64"
    obj = Voice.new('id' => id, 'voice_blob' => Base64.encode64(blob))
    obj.save!
  end


  def cache_image (img_cache,similar_ids, feedbackID)

    obj = Image.new(img_cache)
    obj.save

    expiry_time = Time.now
    expiry_time += 60


    obj = Feedback.new({'id' => feedbackID, 'related' => img_cache['id'], 'tablename' => 0, 'expiry_time' => expiry_time})
    obj.save

    similar_ids.each{|similar|
      obj = Feedback.new({'id' => feedbackID, 'related' => similar, 'tablename' => 1, 'expiry_time' => expiry_time})
      obj.save
    }

    clean_feedback()

  end

  def clean_feedback ()
    expiry_time = Time.now
    puts expiry_time
    feedbacks = Feedback.all
    feedbacks.each{|feedback|
      feedback.destroy if (feedback.expiry_time < expiry_time)
    }
  end


  def cache_learn_new(feedbackID,new_description)
    feedbacks = Feedback.all
    feedbacks.each{|feedback|
      if (feedback.tablename == 1)&&(feedback.id == feedbackID)
        obj = SimilarImages.new("id" =>feedback.related, 'description' =>new_description)
        obj.save
      end
      if (feedback.tablename == 0)&&(feedback.id == feedbackID)
        originalimg = Image.find_by_id(feedback.related)
        obj = Image.new("id" => feedback.related,  "description" => new_description, "verb" => originalimg.verb, "adj" => originalimg.adj )
        obj.save
      end
    }
  end


  def getOppinion(similar_ids)
    answer = Array.new
    similar_ids.each{|similarID|
      obj = SimilarImages.find_by_id(similarID)
      answer.push(obj.description) if obj != nil
    }

    if (answer.length != 0)
      suggestion = answer.group_by{ |i| i }.first()
      suggestion[1] = suggestion[1].length
      return suggestion
    end

    suggestion = Array.new()
    suggestion.push(0);
    suggestion.push(0);
    return suggestion

  end


end