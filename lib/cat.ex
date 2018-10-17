defmodule Cat do
  require Record
  Record.defrecord :cat, name: nil, breed: nil, age: 0
  #efrecord M3U8, program_id: nil, path: nil, bandwidth: nil, ts_files: []

  @type cat :: record(:cat, name: String.t, breed: String.t, age: integer)
end


