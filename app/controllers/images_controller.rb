class ImagesController < ApplicationController
  before_action :set_image, only: [:show, :edit]


  def index

    img_url = params[:imgurl];
    language = params[:lang];

    #img_url = 'scontent-b-lhr.xx.fbcdn.net/hphotos-frc3/v/t1.0-9/1474472_733105713367568_451326057_n.jpg?oh=60affe3c06f32cd8fa914fd83b041e23&oe=5510DE5C'
    it = ImageTranslator.new(language, img_url)
    audio = it.main()

    send_data audio, :type => 'audio/mpeg',:disposition => 'inline'

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
