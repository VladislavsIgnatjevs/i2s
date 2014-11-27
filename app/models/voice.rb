# -*- encoding : utf-8 -*-
class Voice
    include Cequel::Record

    key :id, :varchar
    column :voice_blob, :text

end