# encoding: utf-8
module Mongoid # :nodoc:
  module Relations #:nodoc:
    module Referenced #:nodoc:
      class ManyToMany < Proxy

        # Appends a document or array of documents to the relation. Will set
        # the parent and update the index in the process.
        #
        # Example:
        #
        # <tt>relation << document</tt>
        #
        # Options:
        #
        # docs: Any number of documents.
        def <<(*docs)
          docs.flatten.each do |doc|
            unless target.include?(doc)
              append(doc)
              # doc.save if base.persisted?
            end
          end
        end
        alias :concat :<<
        alias :push :<<

        # Binds the base object to the inverse of the relation. This is so we
        # are referenced to the actual objects themselves and dont hit the
        # database twice when setting the relations up.
        #
        # This is called after first creating the relation, or if a new object
        # is set on the relation.
        #
        # Example:
        #
        # <tt>person.preferences.bind</tt>
        def bind(building = nil)
          # binding.bind
          # target.map(&:save) if base.persisted? && !building?
        end

        # Instantiate a new references_many relation. Will set the foreign key
        # and the base on the inverse object.
        #
        # Example:
        #
        # <tt>Referenced::ManyToMany.new(base, target, metadata)</tt>
        #
        # Options:
        #
        # base: The document this relation hangs off of.
        # target: The target [child documents] of the relation.
        # metadata: The relation's metadata
        def initialize(base, target, metadata)
          init(base, target, metadata)
        end

        private

        # Appends the document to the target array, updating the index on the
        # document at the same time.
        #
        # Example:
        #
        # <tt>relation.append(document)</tt>
        #
        # Options:
        #
        # document: The document to append to the target.
        def append(document)
          target.push(document)
          base.send(metadata.foreign_key).push(document.id)
          # document.send(metadata.foreign_key_setter, base.id)
          # document.send(metadata.inverse_setter(target), base)
          metadatafy(document) # and bind_one(document)
        end

        # Instantiate the binding associated with this relation.
        #
        # Example:
        #
        # <tt>binding([ address ])</tt>
        #
        # Options:
        #
        # new_target: The new documents to bind with.
        #
        # Returns:
        #
        # A binding object.
        def binding(new_target = nil)
          Bindings::Referenced::ManyToMany.new(base, new_target || target, metadata)
        end

        # Will load the target into an array if the target had not already been
        # loaded.
        #
        # Example:
        #
        # <tt>person.addresses.loaded</tt>
        #
        # Returns:
        #
        # The relation itself.
        def loaded
          tap do |relation|
            relation.target = target.entries if target.is_a?(Mongoid::Criteria)
          end
        end

        class << self

          # Return the builder that is responsible for generating the documents
          # that will be used by this relation.
          #
          # Example:
          #
          # <tt>Referenced::ManyToMany.builder(meta, object)</tt>
          #
          # Options:
          #
          # meta: The metadata of the relation.
          # object: A document or attributes to build with.
          #
          # Returns:
          #
          # A newly instantiated builder object.
          def builder(meta, object)
            Builders::Referenced::ManyToMany.new(meta, object)
          end

          # Returns true if the relation is an embedded one. In this case
          # always false.
          #
          # Example:
          #
          # <tt>Referenced::ManyToMany.embedded?</tt>
          #
          # Returns:
          #
          # true
          def embedded?
            false
          end

          def foreign_key_default
            []
          end

          # Returns the suffix of the foreign key field, either "_id" or "_ids".
          #
          # Example:
          #
          # <tt>Referenced::ManyToMany.foreign_key_suffix</tt>
          #
          # Returns:
          #
          # "_id"
          def foreign_key_suffix
            "_ids"
          end

          # Returns the macro for this relation. Used mostly as a helper in
          # reflection.
          #
          # Example:
          #
          # <tt>Mongoid::Relations::Referenced::ManyToMany.macro</tt>
          #
          # Returns:
          #
          # <tt>:references_and_referenced_in_many</tt>
          def macro
            :references_and_referenced_in_many
          end

          # Return the nested builder that is responsible for generating the documents
          # that will be used by this relation.
          #
          # Example:
          #
          # <tt>Referenced::Nested::ManyToMany.builder(attributes, options)</tt>
          #
          # Options:
          #
          # attributes: The attributes to build with.
          # options: The options for the builder.
          #
          # Returns:
          #
          # A newly instantiated nested builder object.
          def nested_builder(metadata, attributes, options)
            Builders::Referenced::Nested::ManyToMany.new(metadata, attributes, options)
          end

          # Tells the caller if this relation is one that stores the foreign
          # key on its own objects.
          #
          # Example:
          #
          # <tt>Referenced::ManyToMany.stores_foreign_key?</tt>
          #
          # Returns:
          #
          # true
          def stores_foreign_key?
            true
          end
        end
      end
    end
  end
end
