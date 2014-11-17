# -*- encoding : utf-8 -*-
class Image
  include Cequel::Record

  key :id, :uuid, auto: true
  column :title, :varchar
  column :description, :text
  column :category, :varchar
  column :image_url, :varchar
  column :voice_url, :varchar
end
