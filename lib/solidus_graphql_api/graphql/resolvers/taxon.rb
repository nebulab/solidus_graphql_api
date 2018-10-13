module Spree
  module GraphQL
    module Resolvers
      class Taxon
        class All
          def self.call(obj, args, ctx)
            Spree::Taxon.all
          end
        end
        class ByTaxonomy
          def self.call(taxonomy, args, ctx)
            # TODO: query(args)
            taxonomy.taxons
          end
        end
      end
    end
  end
end
