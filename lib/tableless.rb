# See #ActiveRecord::Tableless

module ActiveRecord
  
  # = ActiveRecord::Tableless
  # 
  # Allow classes to behave like ActiveRecord models, but without an associated
  # database table. A great way to capitalize on validations. Based on the
  # original post at http://www.railsweenie.com/forums/2/topics/724 (which seems
  # to have disappeared from the face of the earth).
  # 
  # = Example usage
  # 
  #  class ContactMessage < ActiveRecord::Base
  #    
  #    has_no_table
  #    
  #    column :name,    :string
  #    column :email,   :string
  #    column :message, :string
  #    
  #  end
  #  
  #  msg = ContactMessage.new( params[:msg] )
  #  if msg.valid?
  #    ContactMessageSender.deliver_message( msg )
  #    redirect_to :action => :sent
  #  end
  #
  module Tableless
    
    def self.included( base ) #:nodoc:
      base.send( :extend, ClassMethods )
    end
    
    module ClassMethods #:nodoc:
      
      # A model that needs to be tableless will call this method to indicate
      # it.
      def has_no_table
        # keep our options handy
        write_inheritable_attribute(
          :tableless_options,
          :columns => []
        )
        class_inheritable_reader :tableless_options
        
        # extend
        extend  ActiveRecord::Tableless::SingletonMethods
        
        # setup columns
      end
      
    end
    
    module SingletonMethods
      
      # Return the list of columns registered for the model. Used internally by
      # ActiveRecord
      def columns
        tableless_options[:columns]
      end
  
      # Register a new column.
      def column(name, sql_type = nil, default = nil, null = true)
        tableless_options[:columns] << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
      end
      
    end
    
  end
end

ActiveRecord::Base.send( :include, ActiveRecord::Tableless )