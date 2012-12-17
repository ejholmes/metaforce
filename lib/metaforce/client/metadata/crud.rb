module Metaforce
  class Client
    module Metadata
      module CRUD

        def create(*args)
          Job::CRUD.new(metadata, :create, args)
        end

        def update(*args)
          Job::CRUD.new(metadata, :update, args)
        end

        def delete(*args)
          Job::CRUD.new(metadata, :delete, args)
        end
        
      end
    end
  end
end
