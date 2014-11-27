#Description of the picture generated using noun with the the sentence around, which according to english
#language rules has to be with the Indefinite Article + if there is a name(starts with uppercase) then no
#article will be used. Also there is a check of form of the noun(plural or singular)



module DescriptionTextExport


  include ImageToText;
  include CacheKnowledge;
  #module for checking whether to word is of single or plural form
  require 'active_support/inflector'




  def construct(text)
    #here noun is received through the parameter "text"
    #sure this is not working yet
    @noun = text

#Will need to think about adding rules for proper linguistics, as now the methods for pluralizing and singularizing
#are not working with complex words like dresses, which by converting to singular will output DRESSE, but converting
#dress to plural most likely will output DRESSS

#to solve that need to add to the file: config/initializers/inflections.rb
#    ActiveSupport::Inflector.inflections do |inflect|
#      inflect.singular(/ess$/i, 'ess')
#    end
#p.s. added changes to the file now.

#FOR SINGULAR FORM WORDS

#check if the word starts with vovels and is of singular form
    if @noun.start_with?('a','e','i','o','u') && test_singularity(@noun)==true
      #output to terminal
      puts "There is an #{@noun} in this picture"

      #not sure if works, maybe need to make prepared statement

      return "There is an #{@noun} in this picture"




      #check if word starts with consonants and does not contain uppercase letters and is of singular form
    else if !(@noun.start_with?('a','e','i','o','u','y')) && checkUpper==false && test_singularity(@noun)==true

           #output to terminal
           puts "There is a #{@noun} in this picture"

           #not sure if works, maybe need to make prepared statement

           return "There is a #{@noun} in this picture"


           #check if word starts with uppercase vovels and is of singular form
         else if @noun.start_with?('A','E','I','O','U','Y') && test_singularity(@noun)==true

                #output to terminal
                puts "There is #{@noun} in this picture"
                #not sure if works, maybe need to make prepared statement

                return "There is #{@noun} in this picture"

                #check if word starts with uppercase consonants and is of singular form
              else if !(@noun.start_with?('A','E','I','O','U','Y')) && checkUpper==true && test_singularity(@noun)==true

                     #output to terminal
                     puts "There is #{@noun} in this picture"
                     #not sure if works, maybe need to make prepared statement

                     return "There is #{@noun} in this picture"


                     #FOR PLURAL FORM WORDS

                     #check if the word starts with vovels and is of singular form

                     else if @noun.start_with?('a','e','i','o','u') && test_singularity(@noun)==false
                       #output to terminal
                       puts "There is an #{@noun} in this picture"

                       #not sure if works, maybe need to make prepared statement

                       return "There are #{@noun} in this picture"




                       #check if word starts with consonants and does not contain uppercase letters and is of plural form
                     else if !(@noun.start_with?('a','e','i','o','u','y')) && checkUpper==false && test_singularity(@noun)==false

                            #output to terminal
                            puts "There are #{@noun} are this picture"

                            #not sure if works, maybe need to make prepared statement


                            return "There are a #{@noun} in this picture"


                            #check if word starts with uppercase vovels and is of plural form
                          else if @noun.start_with?('A','E','I','O','U','Y') && test_singularity(@noun)==false

                                 #output to terminal
                                 puts "There are #{@noun} in this picture"
                                 #not sure if works, maybe need to make prepared statement

                                 return "There are #{@noun} in this picture"

                                 #check if word starts with uppercase consonants and is of singular form
                               else if !(@noun.start_with?('A','E','I','O','U','Y')) && checkUpper==true && test_singularity(@noun)==false

                                      #output to terminal
                                      puts "There are #{@noun} in this picture"
                                      #not sure if works, maybe need to make prepared statement

                                      return "There are #{@noun} in this picture"






                                    end

                               end
                          end
                     end
                   end
              end

         end
    end
  end




  def checkUpper
    if (/^[[:upper:]]/.match(@noun))
      return true

    else
      return false
    end
  end

  def checkLower
    if !(/^[[:upper:]]/.match(@noun))
      return true

    else
      return false
    end

  end





  #generates new Noun
  def new
    @noun = Noun.new(noun_params)
  end





  def noun_params
    params.require(:noun).permit(:ID)
  end

#next 3 methods are created to test whether the ford is of plural or singular form. If yes then different
#articles are used( there are...)

#test if word is singlular
  def test_singularity(str)
    str.pluralize != str && str.singularize == str
  end
#generate plural form of word
  def pluralize
    ActiveSupport::Inflector.pluralize(self)
  end
#generate singular form of word
  def singularize
    ActiveSupport::Inflector.singularize(self)
  end

end