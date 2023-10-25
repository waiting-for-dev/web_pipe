# frozen_string_literal: true

require 'web_pipe/types'
require 'web_pipe/extensions/params/params/transf'

# :nodoc:
module WebPipe
  # See the docs for the extension linked from the README.
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
        acc >> transformation(t)
      end

      Transf[transformations].call(request.params)
    end

    private

    def transformation(spec)
      transformation = Transf[*spec]
      if (transformation.fn.arity - transformation.args.count) == 1
        transformation
      else
        Transf[spec, self]
      end
    end
  end

  Conn.include(Params)
end
