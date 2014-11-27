class ImagesController < ApplicationController
  before_action :set_image, only: [:show, :edit]
  include ImageToText;
  include CacheKnowledge;
  include DescriptionTextExport;

  def index

    require 'unirest'
    require "base64"



    solution = {}

    img_url = params[:imgurl];
    response = Unirest.get 'http://' + img_url


    #use cahce if it is possible
    img_hash =  Digest::SHA1.hexdigest response.body
    cached_img = Image.find_by_id(img_hash)
    use_cache = true
    if (cached_img != nil)&&(use_cache==true)

      audio = Voice.find(cached_img.description+","+cached_img.verb+","+cached_img.adj)
      solution['audio_response'] = Base64.decode64(audio.voice_blob);
    else

      #for thesting purposes I pass the whole blob. In the final version we will pass the url of the image for the google.
      solution = convertImageToText(response.body)
      feedbackID = SecureRandom.base64(20)




      #get our learned solution
      our_suggestion = getOppinion(solution["similar_ids"]);
      if (our_suggestion[1] > 20)
        solution["description"] = our_suggestion[0]
      end



      puts solution["adj"]
      sentence = solution["adj"] +' '+ solution["verb"]+ ' ' + solution["description"];

      audio_response = Unirest.get 'http://translate.google.com/translate_tts?tl=en&q='+sentence
      solution['audio_response'] = audio_response.body

      cache_image_async({"id" => img_hash,  "description" => solution["description"], "verb" => solution["verb"], "adj" => solution["adj"] }, solution["similar_ids"], feedbackID)

      cache_audio_async(solution["description"]+","+solution["verb"]+","+solution["adj"], solution["audio_response"])

      #render :text =>convert_response["description"]


    end


    #render :text =>solution['audio_response']

    send_data solution['audio_response'], :type => 'audio/mpeg',:disposition => 'inline'



  end

  def new
      @images = Image.all
  end

  def create
    @image = Image.new(image_params)

    respond_to do |format|
      if @image.save
        format.html { redirect_to @image, notice: 'Image was successfully created.' }
        format.json { render :show, status: :created, location: @image }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def show

  end

  def edit
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @image.update(image_params)
        format.html { redirect_to @image, notice: 'Image was successfully updated.' }
        format.json { render :show, status: :ok, location: @image }
      else
        format.html { render :edit }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_image
    @image = Image.find(params[:id])
  end

  def image_params
    params.require(:image).permit(:title, :description, :category, :image_url, :voice_url)
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @image.destroy
    respond_to do |format|
      format.html { redirect_to images_url, notice: 'Image was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
end
