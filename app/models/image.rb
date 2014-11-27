# -*- encoding : utf-8 -*-
class Image
  include Cequel::Record

  key :id, :varchar  #SHA1 checksum
  column :description, :text
  column :verb, :text
  column :adj, :text
end

