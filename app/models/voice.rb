class Voice
    include Cequel::Record

    key :description, :text
    key :verb, :text
    key :adj, :text
    column :voice_blob, :blob

end