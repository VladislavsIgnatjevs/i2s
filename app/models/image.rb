# -*- encoding : utf-8 -*-
class Image
  include Cequel::Record

  key :id, :varchar  #SHA1 checksum
  column :description, :text
  column :category, :varchar
  column :voice_id, :uuid
  column :voice_id2, :uuid
end

