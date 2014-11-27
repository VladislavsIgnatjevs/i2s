class Feedback
  include Cequel::Record
  key :id, :varchar #image id in the database
  key :related, :varchar #image id in the database
  column :tablename, :int
  column :expiry_time, :timestamp
end