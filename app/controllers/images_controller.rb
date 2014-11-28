class ImagesController < ApplicationController
 # before_action :set_image, only: [:show, :edit]

=begin
    The way we send the image through the link:
    localhost:3000/?lang=en&imgurl=www.vetprofessionals.com/catprofessional/images/home-cat.jpg
    lang=en means to which language we want to translate our description to.
    imgurl=.... means the exact link to the image (note no using http:// nor https://)
=end
  def index
    img_url = params[:imgurl]
    language = params[:lang]
    #img_url = 'scontent-b-lhr.xx.fbcdn.net/hphotos-frc3/v/t1.0-9/1474472_733105713367568_451326057_n.jpg?oh=60affe3c06f32cd8fa914fd83b041e23&oe=5510DE5C'
    it = ImageTranslator.new(language, img_url)
    audio = it.main()

    send_data audio, :type => 'audio/mpeg', :disposition => 'inline'
  end

  def show
    @voices = Voice.all
  end
end
