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
      base.send( :extend, ActsMethods )
    end
    
    module ActsMethods #:nodoc:
      
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
        extend  ActiveRecord::Tableless::ClassMethods
        
        # include
        include ActiveRecord::Tableless::InstanceMethods
        
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
      
      %w(find create destroy).each do |m| 
        eval %{ 
          def #{m}
            logger.warn "Can't #{m} a Tableless object"
            false
          end
        }
      end
      
    end
    
    module ClassMethods
          
      def from_query_string(query_string)
        unless query_string.blank?
          params = query_string.split('&').collect do |chunk|
            next if chunk.empty?
            key, value = chunk.split('=', 2)
            next if key.empty?
            value = value.nil? ? nil : CGI.unescape(value)
            [ CGI.unescape(key), value ]
          end.compact.to_h
          
          new(params)
        else
          new
        end
      end
      
    end
    
    module InstanceMethods
    
      def to_query_string(prefix = nil)
        attributes.to_a.collect{|(name,value)| escaped_var_name(name, prefix) + "=" + escape_for_url(value) if value }.compact.join("&")
      end
    
      %w(save destroy).each do |m| 
        eval %{ 
          def #{m}
            logger.warn "Can't #{m} a Tableless object"
            false
          end
        }
      end
      
      private
      
        def escaped_var_name(name, prefix = nil)
          prefix ? "#{URI.escape(prefix)}[#{URI.escape(name)}]" : URI.escape(name)
        end
      
        def escape_for_url(value)
          case value
            when true then "1"
            when false then "0"
            when nil then ""
            else URI.escape(value.to_s)
          end
        rescue
          ""
        end
      
    end
    
  end
end

ActiveRecord::Base.send( :include, ActiveRecord::Tableless )