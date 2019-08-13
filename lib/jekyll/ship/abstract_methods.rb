module Jekyll
  module Ship
    # AbstractMethods when included by a class, allows that class to define
    # 'abstract' methods that need to be implemented by subclasses or else it
    # will throw an error when called.
    module AbstractMethods
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def abstract(abstract_method_name)
          define_method abstract_method_name.to_sym do
            raise "Abstract method :#{abstract_method_name} not implemented in #{self.class}."
          end
        end
      end
    end
  end
end
