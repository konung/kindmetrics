struct StatsDevice
  include JSON::Serializable

  property device : String?

  @[JSON::Field(converter: JSON::IntConverter)]
  property count : Int64

  property percentage : Float32?
end
