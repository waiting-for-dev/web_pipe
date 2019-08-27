require 'web_pipe/types'
require 'web_pipe/extensions/params/params/transf'

module WebPipe
  # Adds a {Conn#params} method which can perform any number of
  # transformations to the request parameters.
  #
  # When no transformations are given, {#params} just returns request
  # parameters (both GET and POST) as a hash:
  #
  # @example
  #   # http://www.example.com?foo=bar
  #   conn.params #=> { 'foo' => 'bar' }
  #
  # Further processing can be specified thanks to `transproc` gem (you
  # need to add it yourself to the Gemfile). All hash transformations
  # in `transproc` are available:
  #
  # @example
  #   # http://www.example.com?foo=bar
  #   conn.params([:deep_symbolize_keys]) #=> { foo: 'bar' }
  #
  # Extra needed arguments can be provided as an array:
  #
  # @example
  #   # http://www.example.com?foo=bar&zoo=zoo
  #   conn.params([:deep_symbolize_keys, [:reject_keys, [:zoo]]) #=> { foo: 'bar' }
  #
  # Instead of injecting transformations at the moment `#params` is
  # called, you can configure them to be automatically used.
  #
  # @example
  #   # http://www.example.com?foo=bar
  #   conn.
  #     add_config(:param_transformations, [:deep_symbolize_keys]).
  #     params #=> { foo: 'bar' }
  #
  # You can register your own transformation functions:
  #
  # @example
  #   # http://www.example.com?foo=bar
  #   fake = ->(_params) { { fake: :params } }
  #   WebPipe::Params::Transf.register(:fake, fake)
  #   conn.params([:fake]) #=> { fake: :params }
  #
  # Your own transformation functions can depend on the {Conn}
  # instance at the moment of execution. For that, just place it as the
  # last argument of the function and it will be curried automatically:
  #
  # @example
  #   # http://www.example.com?foo=bar
  #   add_name = ->(params, conn) { params.merge(name: conn.fetch(:name)) }
  #   WebPipe::Params::Transf.register(:add_name, add_name)
  #   conn.
  #     add(:name, 'Joe').
  #     params([:deep_symbolize_keys, :add_name]) #=> { foo: 'bar', name: 'Joe' }
  #
  # Inline transformations can also be provided:
  #
  # @example
  #   # http://www.example.com?foo=bar
  #   fake = ->(_params) { { fake: :params } }
  #   conn.
  #     params(fake) #=> { fake: :params } 
  #
  # @see https://github.com/solnic/transproc
  module Params
    # Key where configured transformations are set
    PARAM_TRANSFORMATION_KEY = :param_transformations

    # @param transformation_specs [Array<Symbol, Array>, Types::Undefined]
    # @return [Any]
    def params(transformation_specs = Types::Undefined)
      specs = if transformation_specs == Types::Undefined
                fetch_config(PARAM_TRANSFORMATION_KEY, [])
              else
                transformation_specs
              end
      transformations = specs.reduce(Transf[:id]) do |acc, t|
        acc.>>transformation(t)
      end

      Transf[transformations].(request.params)
    end

    private

    def transformation(spec)
      transformation = Transf[*spec]
      if (transformation.fn.arity - transformation.args.count) == 1
        transformation
      else
        Transf[*[spec, self]]
      end
    end
  end

  Conn.include(Params)
end
