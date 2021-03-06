# frozen_string_literal: true

require 'spec_helper'

module Spree::GraphQL
  describe 'Types::Product' do
    let(:description) { '  Not stripped product description  ' }
    let!(:shop) { create(:store) }
    let!(:product) do
      p = create(:product)
      p.description = description
      p.save!
      p
    end
    let!(:product2) do
      p = create(:product)
      p.description = nil
      p.save!
      p
    end
    let!(:ctx) do
      {
        current_store: current_store,
        helpers: double(:helpers)
      }
    end
    let!(:variables) {}

    describe 'fields' do
      let!(:query) do
        %q{
          query {
            shop {
              products(first: 2) {
                edges {
                  node {
                    createdAt
                    updatedAt
                    publishedAt
                    description
                    handle
                    title
                  }
                }
              }
            }
          }
        }
      end
      let!(:result) do
        {
          data: {
            shop: {
              products: {
                edges: [
                  {
                    node: {
                      createdAt: product.created_at.iso8601,
                      publishedAt: product.available_on.iso8601,
                      updatedAt: product.updated_at.iso8601,
                      description: description.strip,
                      handle: product.slug,
                      title: product.name
                    }
                  },
                  {
                    node: {
                      createdAt: product2.created_at.iso8601,
                      publishedAt: product2.available_on.iso8601,
                      updatedAt: product2.updated_at.iso8601,
                      description: '',
                      handle: product2.slug,
                      title: product2.name
                    }
                  }
                ]
              }
            }
          }
          # errors: {},
        }
      end

      it 'succeeds' do
        execute
        expect(response_hash).to eq(result_hash)
      end
    end

    # availableForSale: Indicates if at least one product variant is available for sale.
    # @return [Types::Boolean!]
    describe 'availableForSale' do
      let!(:query) do
        %q{
          query {
            product {
              availableForSale
            }
          }
        }
      end
      let!(:result) do
        {
          data: {
            product: {
              availableForSale: 'Boolean'
            }
          }
          # errors: {},
        }
      end
      # it 'succeeds' do
      #  execute
      #  expect(response_hash).to eq(result_hash)
      # end
    end

    # collections: List of collections a product belongs to.
    # @param reverse [Types::Boolean] (false)
    # @return [Types::Collection.connection_type!]
    describe 'collections' do
      let!(:query) do
        %q{
          query {
            product {
              collections(
                first: Int,
                after: "",
                last: Int,
                before: "",
                reverse: false
              ) {
                edges {
                  node {
                    description
                    handle
                    id
                    image(
                      maxWidth: Int,
                      maxHeight: Int,
                      crop: "CENTER | TOP | BOTTOM | LEFT | RIGHT",
                      scale: Int
                    ) {
                      altText
                      id
                      originalSrc
                      src
                      transformedSrc(
                        maxWidth: Int,
                        maxHeight: Int,
                        crop: "CENTER | TOP | BOTTOM | LEFT | RIGHT",
                        scale: Int,
                        preferredContentType: "PNG | JPG | WEBP"
                      )
                    }
                    products(
                      first: Int,
                      after: "",
                      last: Int,
                      before: "",
                      reverse: false,
                      sortKey: "TITLE | PRICE | BEST_SELLING | CREATED | ID | MANUAL | COLLECTION_DEFAULT | RELEVANCE"
                    ) {
                      edges {
                        # ...
                      }
                      pageInfo {
                        # ...
                      }
                    }
                    title
                    updatedAt
                  }
                }
                pageInfo {
                  hasNextPage
                  hasPreviousPage
                }
              }
            }
          }
        }
      end
      let!(:result) do
        {
          data: {
            product: {
              collections: {
                edges: {
                  node: [{
                    description: 'String',
                    handle: 'String',
                    id: 'ID',
                    image: {
                      altText: 'String',
                      id: 'ID',
                      originalSrc: 'URL',
                      src: 'URL',
                      transformedSrc: 'URL'
                    },
                    products: {
                      edges: {
                        # ...
                      },
                      pageInfo: {
                        # ...
                      }
                    },
                    title: 'String',
                    updatedAt: 'DateTime'
                  }]
                },
                pageInfo: {
                  hasNextPage: true,
                  hasPreviousPage: false
                }
              }
            }
          }
          # errors: {},
        }
      end
      # it 'succeeds' do
      #  execute
      #  expect(response_hash).to eq(result_hash)
      # end
    end

    # images: List of images associated with the product.
    # @param reverse [Types::Boolean] (false)
    # @param sort_key [Types::ProductImageSortKeys] ('POSITION')
    # @param max_width [Types::Int]
    # @param max_height [Types::Int]
    # @param crop [Types::CropRegion]
    # @param scale [Types::Int] (1)
    # @return [Types::Image.connection_type!]
    describe 'images' do
      let!(:query) do
        %q{
          query {
            product {
              images(
                first: Int,
                after: "",
                last: Int,
                before: "",
                reverse: false,
                sortKey: "CREATED_AT | POSITION | ID | RELEVANCE",
                maxWidth: Int,
                maxHeight: Int,
                crop: "CENTER | TOP | BOTTOM | LEFT | RIGHT",
                scale: Int
              ) {
                edges {
                  node {
                    altText
                    id
                    originalSrc
                    src
                    transformedSrc(
                      maxWidth: Int,
                      maxHeight: Int,
                      crop: "CENTER | TOP | BOTTOM | LEFT | RIGHT",
                      scale: Int,
                      preferredContentType: "PNG | JPG | WEBP"
                    )
                  }
                }
                pageInfo {
                  hasNextPage
                  hasPreviousPage
                }
              }
            }
          }
        }
      end
      let!(:result) do
        {
          data: {
            product: {
              images: {
                edges: {
                  node: [{
                    altText: 'String',
                    id: 'ID',
                    originalSrc: 'URL',
                    src: 'URL',
                    transformedSrc: 'URL'
                  }]
                },
                pageInfo: {
                  hasNextPage: true,
                  hasPreviousPage: false
                }
              }
            }
          }
          # errors: {},
        }
      end
      # it 'succeeds' do
      #  execute
      #  expect(response_hash).to eq(result_hash)
      # end
    end

    # onlineStoreUrl: The online store URL for the product. A value of `null` indicates that the product is not published to the Online Store sales channel.
    # @return [Types::URL]
    describe 'onlineStoreUrl' do
      let!(:query) do
        %q{
          query {
            product {
              onlineStoreUrl
            }
          }
        }
      end
      let!(:result) do
        {
          data: {
            product: {
              onlineStoreUrl: 'URL'
            }
          }
          # errors: {},
        }
      end
      # it 'succeeds' do
      #  execute
      #  expect(response_hash).to eq(result_hash)
      # end
    end

    # options: List of custom product options (maximum of 3 per product).
    # @param first [Types::Int]
    # @return [[Types::ProductOption!]!]
    describe 'options' do
      let!(:query) do
        %q{
          query {
            product {
              options(first: Int) {
                id
                name
                values
              }
            }
          }
        }
      end
      let!(:result) do
        {
          data: {
            product: {
              options: [{
                id: 'ID',
                name: 'String',
                values: 'String'
              }]
            }
          }
          # errors: {},
        }
      end
      # it 'succeeds' do
      #  execute
      #  expect(response_hash).to eq(result_hash)
      # end
    end

    # priceRange: The price range.
    # @return [Types::ProductPriceRange!]
    describe 'priceRange' do
      let!(:query) do
        %q{
          query {
            product {
              priceRange {
                maxVariantPrice {
                  amount
                  currencyCode
                }
                minVariantPrice {
                  amount
                  currencyCode
                }
              }
            }
          }
        }
      end
      let!(:result) do
        {
          data: {
            product: {
              priceRange: {
                maxVariantPrice: {
                  amount: 'Decimal',
                  currencyCode: 'USD | EUR | GBP | CAD | AFN | ALL | DZD | AOA | ARS | AMD | AWG | AUD | BBD | AZN | BDT | BSD | BHD | BIF | BYR | BZD | BTN | BAM | BRL | BOB | BWP | BND | BGN | MMK | KHR | CVE | KYD | XAF | CLP | CNY | COP | KMF | CDF | CRC | HRK | CZK | DKK | DOP | XCD | EGP | ETB | XPF | FJD | GMD | GHS | GTQ | GYD | GEL | HTG | HNL | HKD | HUF | ISK | INR | IDR | ILS | IQD | JMD | JPY | JEP | JOD | KZT | KES | KWD | KGS | LAK | LVL | LBP | LSL | LRD | LTL | MGA | MKD | MOP | MWK | MVR | MXN | MYR | MUR | MDL | MAD | MNT | MZN | NAD | NPR | ANG | NZD | NIO | NGN | NOK | OMR | PKR | PGK | PYG | PEN | PHP | PLN | QAR | RON | RUB | RWF | WST | SAR | STD | RSD | SCR | SGD | SDG | SYP | ZAR | KRW | SSP | SBD | LKR | SRD | SZL | SEK | CHF | TWD | THB | TZS | TTD | TND | TRY | TMT | UGX | UAH | AED | UYU | UZS | VUV | VEF | VND | XOF | YER | ZMW'
                },
                minVariantPrice: {
                  amount: 'Decimal',
                  currencyCode: 'USD | EUR | GBP | CAD | AFN | ALL | DZD | AOA | ARS | AMD | AWG | AUD | BBD | AZN | BDT | BSD | BHD | BIF | BYR | BZD | BTN | BAM | BRL | BOB | BWP | BND | BGN | MMK | KHR | CVE | KYD | XAF | CLP | CNY | COP | KMF | CDF | CRC | HRK | CZK | DKK | DOP | XCD | EGP | ETB | XPF | FJD | GMD | GHS | GTQ | GYD | GEL | HTG | HNL | HKD | HUF | ISK | INR | IDR | ILS | IQD | JMD | JPY | JEP | JOD | KZT | KES | KWD | KGS | LAK | LVL | LBP | LSL | LRD | LTL | MGA | MKD | MOP | MWK | MVR | MXN | MYR | MUR | MDL | MAD | MNT | MZN | NAD | NPR | ANG | NZD | NIO | NGN | NOK | OMR | PKR | PGK | PYG | PEN | PHP | PLN | QAR | RON | RUB | RWF | WST | SAR | STD | RSD | SCR | SGD | SDG | SYP | ZAR | KRW | SSP | SBD | LKR | SRD | SZL | SEK | CHF | TWD | THB | TZS | TTD | TND | TRY | TMT | UGX | UAH | AED | UYU | UZS | VUV | VEF | VND | XOF | YER | ZMW'
                }
              }
            }
          }
          # errors: {},
        }
      end
      # it 'succeeds' do
      #  execute
      #  expect(response_hash).to eq(result_hash)
      # end
    end

    # productType: A categorization that a product can be tagged with, commonly used for filtering and searching.
    # @return [Types::String!]
    describe 'productType' do
      let!(:query) do
        %q{
          query {
            product {
              productType
            }
          }
        }
      end
      let!(:result) do
        {
          data: {
            product: {
              productType: 'String'
            }
          }
          # errors: {},
        }
      end
      # it 'succeeds' do
      #  execute
      #  expect(response_hash).to eq(result_hash)
      # end
    end

    # tags: A categorization that a product can be tagged with, commonly used for filtering and searching. Each comma-separated tag has a character limit of 255.
    # @return [[Types::String!]!]
    describe 'tags' do
      let!(:query) do
        %q{
          query {
            product {
              tags
            }
          }
        }
      end
      let!(:result) do
        {
          data: {
            product: {
              tags: ['String']
            }
          }
          # errors: {},
        }
      end
      # it 'succeeds' do
      #  execute
      #  expect(response_hash).to eq(result_hash)
      # end
    end

    # variantBySelectedOptions: Find a product’s variant based on its selected options. This is useful for converting a user’s selection of product options into a single matching variant. If there is not a variant for the selected options, `null` will be returned.
    # @param selected_options [[Inputs::SelectedOption!]!]
    # @return [Types::ProductVariant]
    describe 'variantBySelectedOptions' do
      let!(:query) do
        %q{
          query {
            product {
              variantBySelectedOptions(
                selectedOptions: [{
                  name: "String",
                  value: "String"
                }]
              ) {
                available
                availableForSale
                compareAtPrice
                id
                image(
                  maxWidth: Int,
                  maxHeight: Int,
                  crop: "CENTER | TOP | BOTTOM | LEFT | RIGHT",
                  scale: Int
                ) {
                  altText
                  id
                  originalSrc
                  src
                  transformedSrc(
                    maxWidth: Int,
                    maxHeight: Int,
                    crop: "CENTER | TOP | BOTTOM | LEFT | RIGHT",
                    scale: Int,
                    preferredContentType: "PNG | JPG | WEBP"
                  )
                }
                price
                product {
                  availableForSale
                  collections(
                    first: Int,
                    after: "",
                    last: Int,
                    before: "",
                    reverse: false
                  ) {
                    edges {
                      node {
                        # ...
                      }
                    }
                    pageInfo {
                      hasNextPage
                      hasPreviousPage
                    }
                  }
                  createdAt
                  description
                  handle
                  id
                  images(
                    first: Int,
                    after: "",
                    last: Int,
                    before: "",
                    reverse: false,
                    sortKey: "CREATED_AT | POSITION | ID | RELEVANCE",
                    maxWidth: Int,
                    maxHeight: Int,
                    crop: "CENTER | TOP | BOTTOM | LEFT | RIGHT",
                    scale: Int
                  ) {
                    edges {
                      node {
                        # ...
                      }
                    }
                    pageInfo {
                      hasNextPage
                      hasPreviousPage
                    }
                  }
                  onlineStoreUrl
                  options(first: Int) {
                    id
                    name
                    values
                  }
                  priceRange {
                    maxVariantPrice {
                      amount
                      currencyCode
                    }
                    minVariantPrice {
                      amount
                      currencyCode
                    }
                  }
                  productType
                  publishedAt
                  tags
                  title
                  updatedAt
                  variantBySelectedOptions(
                    selectedOptions: [{
                      name: "String",
                      value: "String"
                    }]
                  )
                  variants(
                    first: Int,
                    after: "",
                    last: Int,
                    before: "",
                    reverse: false,
                    sortKey: "TITLE | SKU | POSITION | ID | RELEVANCE"
                  ) {
                    edges {
                      node
                    }
                    pageInfo {
                      hasNextPage
                      hasPreviousPage
                    }
                  }
                  vendor
                }
                selectedOptions {
                  name
                  value
                }
                sku
                title
                weight
                weightUnit
              }
            }
          }
        }
      end
      let!(:result) do
        {
          data: {
            product: {
              variantBySelectedOptions: {
                available: 'Boolean',
                availableForSale: 'Boolean',
                compareAtPrice: 'Money',
                id: 'ID',
                image: {
                  altText: 'String',
                  id: 'ID',
                  originalSrc: 'URL',
                  src: 'URL',
                  transformedSrc: 'URL'
                },
                price: 'Money',
                product: {
                  availableForSale: 'Boolean',
                  collections: {
                    edges: {
                      node: [{
                        # ...
                      }]
                    },
                    pageInfo: {
                      hasNextPage: true,
                      hasPreviousPage: false
                    }
                  },
                  createdAt: 'DateTime',
                  description: 'String',
                  handle: 'String',
                  id: 'ID',
                  images: {
                    edges: {
                      node: [{
                        # ...
                      }]
                    },
                    pageInfo: {
                      hasNextPage: true,
                      hasPreviousPage: false
                    }
                  },
                  onlineStoreUrl: 'URL',
                  options: {
                    id: 'ID',
                    name: 'String',
                    values: 'String'
                  },
                  priceRange: {
                    maxVariantPrice: {
                      amount: 'Decimal',
                      currencyCode: 'USD | EUR | GBP | CAD | AFN | ALL | DZD | AOA | ARS | AMD | AWG | AUD | BBD | AZN | BDT | BSD | BHD | BIF | BYR | BZD | BTN | BAM | BRL | BOB | BWP | BND | BGN | MMK | KHR | CVE | KYD | XAF | CLP | CNY | COP | KMF | CDF | CRC | HRK | CZK | DKK | DOP | XCD | EGP | ETB | XPF | FJD | GMD | GHS | GTQ | GYD | GEL | HTG | HNL | HKD | HUF | ISK | INR | IDR | ILS | IQD | JMD | JPY | JEP | JOD | KZT | KES | KWD | KGS | LAK | LVL | LBP | LSL | LRD | LTL | MGA | MKD | MOP | MWK | MVR | MXN | MYR | MUR | MDL | MAD | MNT | MZN | NAD | NPR | ANG | NZD | NIO | NGN | NOK | OMR | PKR | PGK | PYG | PEN | PHP | PLN | QAR | RON | RUB | RWF | WST | SAR | STD | RSD | SCR | SGD | SDG | SYP | ZAR | KRW | SSP | SBD | LKR | SRD | SZL | SEK | CHF | TWD | THB | TZS | TTD | TND | TRY | TMT | UGX | UAH | AED | UYU | UZS | VUV | VEF | VND | XOF | YER | ZMW'
                    },
                    minVariantPrice: {
                      amount: 'Decimal',
                      currencyCode: 'USD | EUR | GBP | CAD | AFN | ALL | DZD | AOA | ARS | AMD | AWG | AUD | BBD | AZN | BDT | BSD | BHD | BIF | BYR | BZD | BTN | BAM | BRL | BOB | BWP | BND | BGN | MMK | KHR | CVE | KYD | XAF | CLP | CNY | COP | KMF | CDF | CRC | HRK | CZK | DKK | DOP | XCD | EGP | ETB | XPF | FJD | GMD | GHS | GTQ | GYD | GEL | HTG | HNL | HKD | HUF | ISK | INR | IDR | ILS | IQD | JMD | JPY | JEP | JOD | KZT | KES | KWD | KGS | LAK | LVL | LBP | LSL | LRD | LTL | MGA | MKD | MOP | MWK | MVR | MXN | MYR | MUR | MDL | MAD | MNT | MZN | NAD | NPR | ANG | NZD | NIO | NGN | NOK | OMR | PKR | PGK | PYG | PEN | PHP | PLN | QAR | RON | RUB | RWF | WST | SAR | STD | RSD | SCR | SGD | SDG | SYP | ZAR | KRW | SSP | SBD | LKR | SRD | SZL | SEK | CHF | TWD | THB | TZS | TTD | TND | TRY | TMT | UGX | UAH | AED | UYU | UZS | VUV | VEF | VND | XOF | YER | ZMW'
                    }
                  },
                  productType: 'String',
                  publishedAt: 'DateTime',
                  tags: 'String',
                  title: 'String',
                  updatedAt: 'DateTime',
                  variantBySelectedOptions: 'ProductVariant...',
                  variants: {
                    edges: {
                      node: ['ProductVariant...']
                    },
                    pageInfo: {
                      hasNextPage: true,
                      hasPreviousPage: false
                    }
                  },
                  vendor: 'String'
                },
                selectedOptions: {
                  name: 'String',
                  value: 'String'
                },
                sku: 'String',
                title: 'String',
                weight: 'Float',
                weightUnit: 'KILOGRAMS | GRAMS | POUNDS | OUNCES'
              }
            }
          }
          # errors: {},
        }
      end
      # it 'succeeds' do
      #  execute
      #  expect(response_hash).to eq(result_hash)
      # end
    end

    # variants: List of the product’s variants.
    # @param reverse [Types::Boolean] (false)
    # @param sort_key [Types::ProductVariantSortKeys] ('POSITION')
    # @return [Types::ProductVariant.connection_type!]
    describe 'variants' do
      let!(:query) do
        %q{
          query {
            product {
              variants(
                first: Int,
                after: "",
                last: Int,
                before: "",
                reverse: false,
                sortKey: "TITLE | SKU | POSITION | ID | RELEVANCE"
              ) {
                edges {
                  node {
                    available
                    availableForSale
                    compareAtPrice
                    id
                    image(
                      maxWidth: Int,
                      maxHeight: Int,
                      crop: "CENTER | TOP | BOTTOM | LEFT | RIGHT",
                      scale: Int
                    ) {
                      altText
                      id
                      originalSrc
                      src
                      transformedSrc(
                        maxWidth: Int,
                        maxHeight: Int,
                        crop: "CENTER | TOP | BOTTOM | LEFT | RIGHT",
                        scale: Int,
                        preferredContentType: "PNG | JPG | WEBP"
                      )
                    }
                    price
                    product {
                      availableForSale
                      collections(
                        first: Int,
                        after: "",
                        last: Int,
                        before: "",
                        reverse: false
                      ) {
                        # ...
                      }
                      createdAt
                      description
                      handle
                      id
                      images(
                        first: Int,
                        after: "",
                        last: Int,
                        before: "",
                        reverse: false,
                        sortKey: "CREATED_AT | POSITION | ID | RELEVANCE",
                        maxWidth: Int,
                        maxHeight: Int,
                        crop: "CENTER | TOP | BOTTOM | LEFT | RIGHT",
                        scale: Int
                      ) {
                        # ...
                      }
                      onlineStoreUrl
                      options(first: Int) {
                        # ...
                      }
                      priceRange {
                        # ...
                      }
                      productType
                      publishedAt
                      tags
                      title
                      updatedAt
                      variantBySelectedOptions(
                        selectedOptions: [{
                          name: "String",
                          value: "String"
                        }]
                      )
                      variants(
                        first: Int,
                        after: "",
                        last: Int,
                        before: "",
                        reverse: false,
                        sortKey: "TITLE | SKU | POSITION | ID | RELEVANCE"
                      ) {
                        # ...
                      }
                      vendor
                    }
                    selectedOptions {
                      name
                      value
                    }
                    sku
                    title
                    weight
                    weightUnit
                  }
                }
                pageInfo {
                  hasNextPage
                  hasPreviousPage
                }
              }
            }
          }
        }
      end
      let!(:result) do
        {
          data: {
            product: {
              variants: {
                edges: {
                  node: [{
                    available: 'Boolean',
                    availableForSale: 'Boolean',
                    compareAtPrice: 'Money',
                    id: 'ID',
                    image: {
                      altText: 'String',
                      id: 'ID',
                      originalSrc: 'URL',
                      src: 'URL',
                      transformedSrc: 'URL'
                    },
                    price: 'Money',
                    product: {
                      availableForSale: 'Boolean',
                      collections: {
                        # ...
                      },
                      createdAt: 'DateTime',
                      description: 'String',
                      handle: 'String',
                      id: 'ID',
                      images: {
                        # ...
                      },
                      onlineStoreUrl: 'URL',
                      options: {
                        # ...
                      },
                      priceRange: {
                        # ...
                      },
                      productType: 'String',
                      publishedAt: 'DateTime',
                      tags: 'String',
                      title: 'String',
                      updatedAt: 'DateTime',
                      variantBySelectedOptions: 'ProductVariant...',
                      variants: {
                        # ...
                      },
                      vendor: 'String'
                    },
                    selectedOptions: {
                      name: 'String',
                      value: 'String'
                    },
                    sku: 'String',
                    title: 'String',
                    weight: 'Float',
                    weightUnit: 'KILOGRAMS | GRAMS | POUNDS | OUNCES'
                  }]
                },
                pageInfo: {
                  hasNextPage: true,
                  hasPreviousPage: false
                }
              }
            }
          }
          # errors: {},
        }
      end
      # it 'succeeds' do
      #  execute
      #  expect(response_hash).to eq(result_hash)
      # end
    end

    # vendor: The product’s vendor name.
    # @return [Types::String!]
    describe 'vendor' do
      let!(:query) do
        %q{
          query {
            product {
              vendor
            }
          }
        }
      end
      let!(:result) do
        {
          data: {
            product: {
              vendor: 'String'
            }
          }
          # errors: {},
        }
      end
      # it 'succeeds' do
      #  execute
      #  expect(response_hash).to eq(result_hash)
      # end
    end
  end
end
