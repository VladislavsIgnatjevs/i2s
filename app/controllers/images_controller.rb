class ImagesController < ApplicationController
  before_action :set_image, only: [:show, :edit]
  include ImageToText;
  include CacheKnowledge;

  def index

    require 'unirest'





    img_url = params[:imgurl];
    response = Unirest.get 'http://' + img_url


    img_hash =  Digest::SHA1.hexdigest response.body
    cached_img = Image.find_by_id(img_hash)

    if (cached_img != nil)
      render :text =>cached_img.description
    else
      #for thesting purposes I pass the whole blob. In the final version we will pass the url of the image for the google.
      description = convertImageToText(response.body);
      cache_it_async({"id" => img_hash, "category" => nil, "description" => description, "voice_id" => nil })
      render :text =>description
    end







  end

  def new
      @image = Image.new
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
