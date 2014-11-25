class Voice
    include Cequel::Record
    key :id, :uuid, auto:true
    column :voice_blob, :blob

end