class SimilarImages
  include Cequel::Record

  key :id, :varchar #image id in the database
  column :description, :text

end