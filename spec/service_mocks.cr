##################
# FIBER SPECIFIC #
##################
@[ADI::Register(public: true)]
class ValueStore
  property value : Int32 = 1
end

##############
# NAMESPACED #
##############
@[ADI::Register(public: true)]
class MyApp::Models::Foo
end

@[ADI::Register(public: true)]
class NamespaceClient
  getter service

  def initialize(@service : MyApp::Models::Foo); end
end

###############
# SINGLE TYPE #
###############
@[ADI::Register]
class SingleService
  getter value : Int32 = 1
end

@[ADI::Register(public: true)]
class SingleClient
  getter service : SingleService

  def initialize(@service : SingleService); end
end

#################
# MULTIPLE TYPE #
#################
module TransformerInterface
end

@[ADI::Register(alias: TransformerInterface, type: TransformerInterface, public: true)]
struct ReverseTransformer
  include TransformerInterface
end

@[ADI::Register]
struct ShoutTransformer
  include TransformerInterface
end

@[ADI::Register(public: true)]
class TransformerAliasClient
  getter service

  def initialize(transformer : TransformerInterface)
    @service = transformer
  end
end

@[ADI::Register(public: true)]
class TransformerAliasNameClient
  getter service

  def initialize(shout_transformer : TransformerInterface)
    @service = shout_transformer
  end
end

######################
# OVERRIDING ALIASES #
######################
module ConverterInterface
end

@[ADI::Register(alias: ConverterInterface)]
struct ConverterOne
  include ConverterInterface
end

@[ADI::Register(alias: ConverterInterface, public_alias: true)]
struct ConverterTwo
  include ConverterInterface
end

####################
# OPTIONAL SERVICE #
####################
struct OptionalMissingService
end

@[ADI::Register]
struct OptionalExistingService
end

@[ADI::Register(public: true)]
class OptionalClient
  getter service_missing, service_existing, service_default

  def initialize(
    @service_missing : OptionalMissingService?,
    @service_existing : OptionalExistingService?,
    @service_default : OptionalMissingService | Int32 | Nil = 12
  ); end
end

###################
# GENERIC SERVICE #
###################
@[ADI::Register(Int32, Bool, public: true, name: "int_service")]
@[ADI::Register(Float64, Bool, public: true, name: "float_service")]
struct GenericServiceBase(T, B)
  def type
    {T, B}
  end
end

##################
# SCALAR SERVICE #
##################
@[ADI::Register(_value: 22, _array: [1, 2, 3], _named_tuple: {id: 17_i64, active: true}, public: true)]
struct ScalarClient
  getter value, array, named_tuple

  def initialize(@value : Int32, @array : Array(Int32), @named_tuple : NamedTuple(id: Int64, active: Bool)); end
end

#################
# ARRAY SERVICE #
#################
module ArrayInterface
end

@[ADI::Register]
struct ArrayService
  include ArrayInterface
end

@[ADI::Register]
struct API::Models::NestedArrayService
  include ArrayInterface
end

@[ADI::Register(_services: ["@array_service", "@api_models_nested_array_service"], public: true)]
struct ArrayClient
  getter services

  def initialize(@services : Array(ArrayInterface?)); end
end

@[ADI::Register(_values: [1, 2, 3], public: true)]
struct ArrayValueDefaultClient
  getter values
  getter status

  def initialize(
    @values : Array(Int32),
    @status : Status = Status::Active
  ); end
end

##################
# TAGGED SERVICE #
##################
private PARTNER_TAG = "partner"

enum Status
  Active
  Inactive
end

@[ADI::Register(_id: 1, name: "google", tags: [{name: PARTNER_TAG, priority: 5}])]
@[ADI::Register(_id: 2, name: "facebook", tags: [PARTNER_TAG])]
@[ADI::Register(_id: 3, name: "yahoo", tags: [{name: "partner", priority: 10}])]
@[ADI::Register(_id: 4, name: "microsoft", tags: [PARTNER_TAG])]
struct FeedPartner
  getter id

  def initialize(@id : Int32); end
end

@[ADI::Register(_services: "!partner", public: true)]
class PartnerClient
  getter services

  def initialize(@services : Array(FeedPartner))
  end
end

@[ADI::Register(_services: "!partner", public: true)]
class PartnerNamedDefaultClient
  getter services
  getter status

  def initialize(
    @services : Array(FeedPartner),
    @status : Status = Status::Active
  )
  end
end

############
# BINDINGS #
############
private PRIME_VALUE = "prime_value"

module ValueInterface; end

@[ADI::Register(_value: 1, name: "value_one")]
@[ADI::Register(_value: 2, name: "value_two", tags: [PRIME_VALUE])]
@[ADI::Register(_value: 3, name: "value_three", tags: [PRIME_VALUE])]
record ValueService, value : Int32 do
  include ValueInterface
end

ADI.bind override_binding, 1
ADI.bind override_binding, 2
ADI.bind api_key, "123ABC"
ADI.bind config, {id: 12_i64, active: true}
ADI.bind odd_values, ["@value_one", "@value_three"]
ADI.bind prime_values, "!prime_value"

@[ADI::Register(public: true)]
record BindingClient,
  override_binding : Int32,
  api_key : String,
  config : NamedTuple(id: Int64, active: Bool),
  odd_values : Array(ValueInterface),
  prime_values : Array(ValueInterface)

# Bindings with same name, but diff restrictions
ADI.bind values : Array(String), ["one", "two", "three"]
ADI.bind values : Array(Int32), [1, 2, 3]

# Override bindings with different (but still compatible) type restriction
ADI.bind debug : Bool, false
ADI.bind debug : Int32, 0

# Override bindings with same type restriction
ADI.bind typed_value : String, "foo"
ADI.bind typed_value : String, "bar"

# Correctly handles type and untyped bindings of same name.
# Should try typed bindings first since they are more specific,
# otherwise falling back on last defined untyped binding
ADI.bind mixed_type_value : Bool, true
ADI.bind mixed_type_value, 2
ADI.bind mixed_type_value, 1

@[ADI::Register(public: true)]
record TypedBindingClient,
  debug : Int32 | Bool,
  typed_value : String

@[ADI::Register(public: true)]
record MixedUntypedBindingClient,
  mixed_type_value : Int32

@[ADI::Register(public: true)]
record MixedTypedBindingClient,
  mixed_type_value : Bool

@[ADI::Register(public: true)]
record MixedBothBindingClient,
  mixed_type_value : Bool | Int32

@[ADI::Register(public: true)]
record IntArrClient, values : Array(Int32)

@[ADI::Register(public: true)]
record StrArrClient, values : Array(String)

@[ADI::Register(public: true)]
record IntArrDefaultClient,
  values : Array(Int32),
  status : Status = Status::Active

@[ADI::Register(public: true)]
record PrimeArrDefaultClient,
  prime_values : Array(ValueInterface),
  status : Status = Status::Active

######################
# AUTO CONFIGURATION #
######################
module ConfigInterface; end

@[ADI::Register]
record ConfigOne do
  include ConfigInterface
end

@[ADI::Register]
record ConfigTwo do
  include ConfigInterface
end

@[ADI::Register(tags: [] of String)]
record ConfigThree do
  include ConfigInterface
end

@[ADI::Register]
struct ConfigFour
  class_getter? initialized : Bool = false

  def initialize
    @@initialized = true
  end
end

@[ADI::Register]
struct ConfigFive
  class_getter? initialized : Bool = false

  def initialize
    @@initialized = true
  end
end

@[ADI::Register(_configs: "!config", public: true)]
record ConfigClient, configs : Array(ConfigInterface)

ADI.auto_configure ConfigInterface, {tags: ["config"]}
ADI.auto_configure ConfigFour, {public: true, lazy: false}

#############
# FACTORIES #
#############
class TestFactory
  def self.create_factory_tuple(value : Int32) : FactoryTuple
    FactoryTuple.new value * 3
  end

  def self.create_factory_service(value_provider : ValueProvider) : FactoryService
    FactoryService.new value_provider.value
  end
end

@[ADI::Register(_value: 10, public: true, factory: {TestFactory, "create_factory_tuple"})]
class FactoryTuple
  getter value : Int32

  def initialize(@value : Int32); end
end

@[ADI::Register(_value: 10, public: true, factory: "double")]
class FactoryString
  getter value : Int32

  def self.double(value : Int32) : self
    new value * 2
  end

  def initialize(@value : Int32); end
end

@[ADI::Register]
record ValueProvider, value : Int32 = 10

@[ADI::Register(public: true, factory: {TestFactory, "create_factory_service"})]
class FactoryService
  getter value : Int32

  def initialize(@value : Int32); end
end
