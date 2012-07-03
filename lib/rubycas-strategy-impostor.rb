require "rubycas-strategy-impostor/version"
require "sequel"

module CASServer
  module Strategy
    module Impostor
      class Worker
        def initialize(config)
          raise "Expecting config" unless config.is_a?(::Hash)
          @config = config

          @connection = Sequel.connect(config['database'])
          @dataset = @connection.from( @config['user_table'] )
        end

        def has_required_role?(username)
          !@dataset.
            join( :"#{@config['join_table']}", :"#{@config['user_key']}" => :id ).
            join( :"#{@config['role_table']}", :id => :"#{@config['role_key']}" ).
            where( :"#{@config['user_table']}__#{@config['username_column']}" => username ).
            where( :"#{@config['role_table']}__#{@config['role_name_column']}" => @config['allowed_roles'] ).
            empty?
        end

        def steal(requester, target)
          if has_required_role? requester
            match = @dataset.where( :"#{@config['username_column']}" => target )
            raise "Multiple matches, database tainted" if match.count > 1
            match.first.nil? ? false : match.first[:"#{@config['username_column']}"]
          else
            false
          end
        end
      end

      def self.registered(app)
        settings = app.workhorse

        app.set :impostor_worker, Worker.new(settings)

        app.get "#{app.uri_path}/impostor/:username" do
          # Direct copy from rubycas-server login action
          # TODO: Move it to a method?
          if tgc = request.cookies['tgt']
            tgt, tgt_error = validate_ticket_granting_ticket(tgc)
          end

          if tgt and !tgt_error
            match = app.settings.impostor_worker.steal(tgt.username, params[:username])
            establish_session! match if match
          end
          # Copy end

          # Redirect to login page if we're still here.
          redirect to("#{app.uri_path}/login"), 303
        end
      end
    end
  end
end
