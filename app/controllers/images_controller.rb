class ImagesController < ApplicationController
  before_action :set_image, only: [:show, :edit]
  include ImageToText;
  include CacheKnowledge;
  include DescriptionTextExport;

  def index

    require 'unirest'





    img_url = params[:imgurl];
    response = Unirest.get 'http://' + img_url


    img_hash =  Digest::SHA1.hexdigest response.body
    cached_img = Image.find_by_id(img_hash)

    use_cache = false

    if (cached_img != nil)&&(use_cache==true)
      render :text =>cached_img.description
    else

      #for thesting purposes I pass the whole blob. In the final version we will pass the url of the image for the google.
      convert_response = convertImageToText(response.body)
      feedbackID = SecureRandom.base64(20)
      cache_it_async({"id" => img_hash,  "description" => convert_response["description"], "verb" => nil, "adj" => nil }, convert_response["similar_ids"], feedbackID)


      our_suggestion = getOppinion(convert_response["similar_ids"]);
      if (our_suggestion[1] > 20)
        convert_response["description"] = our_suggestion[0]
      end

      #aresponse = Unirest.get 'http://translate.google.com/translate_tts?tl=en&q='+ construct(convert_response["description"])

      #send_data aresponse.body, :type => 'audio/mpeg',:disposition => 'inline'
      render :text =>convert_response["description"]
    end







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
